--Medikamente mit Infos in ABDATA
  (
    SELECT 	
          'TRUE' AS "abdataInfos", 
          m.MID, 
          m.ACTIVE, 
          m.ATC, 
          info.pzn, 
          m.TRADENAME, 
          m.PHARMACEUTICAL_FORM, 
          m.REFERENCE_VALUE, 
          m.REFERENCE_UNIT, 
          esc.KEY_STO AS "Key_Sto",
          CASE 	WHEN esc.TYP = 1 THEN 'ASK'
                WHEN esc.TYP = 4 THEN 'CAS'
                END AS "Stoff_Typ",
          esc.externer_Code, 
          sna.NAME AS "Name", 
          fai.zahl AS "Zahl", 
          fai.einheit AS "Einheit", 
          fai.STOFFTYP AS "Typ"
    FROM 
          PHOENIX.MEDICAMENT m 
		LEFT JOIN PHOENIX.ABDA_FAI_MED_OBJECT fai --Wirkstoffe im Medikament
          ON SUBSTRING(m.SOURCE_ID,1) = SUBSTRING(fai.KEY_FAM,1) 
		LEFT JOIN PHOENIX.ABDA_ESC_MED_OBJECT esc 
          ON fai.KEY_STO = esc.KEY_STO 
		LEFT JOIN PHOENIX.ABDA_SNA_MED_OBJECT sna --Wirkstoffnamen
          ON esc.KEY_STO = sna.KEY_STO  
		LEFT JOIN 
       (SELECT a.id, a.pzn, a.mid FROM PHOENIX.HOSPITAL_MEDICAMENT_INFO a 
           INNER JOIN 
                (SELECT mid, MAX(id) maxid FROM PHOENIX.HOSPITAL_MEDICAMENT_INFO GROUP BY mid) b 
                    ON a.id = b.maxid
       ) info --Medikamenteninfo um PZN zu erhalten
           ON info.MID = m.MID
    WHERE m.MID = ${midCounter}
    AND m.recent = true
    AND (esc.TYP = 1 OR esc.TYP = 4) --1 ASK, 4 CAS
    AND (sna.VORZUGSBEZEICHNUNG = TRUE) --Wirkstoffname nur die Vorzugsbezeichnung
  )
UNION 
-- Medikamente ohne ABDATA
  (
    SELECT 
           'FALSE' AS "abdataInfos", 
           m.MID, 
           m.ACTIVE, 
           m.ATC, 
           info.pzn, 
           m.TRADENAME, 
           m.PHARMACEUTICAL_FORM, 
           m.REFERENCE_VALUE, 
           m.REFERENCE_UNIT, 
           NULL AS "Key_Sto",       
           NULL AS "Stoff_Typ", 
           NULL AS "externer_Code", 
           i.Name AS "Name", 
           i.AMOUNT AS "Zahl", 
           i.UNIT AS "Einheit", 
           i.INGREDIENT_TYPE AS "Typ"
    FROM 
           PHOENIX.MEDICAMENT m 
		LEFT JOIN PHOENIX.INGREDIENT i --Ingredientsinfos für die Stärke
           ON m.MID = i.MEDICAMENT 	
		LEFT JOIN 
       (SELECT a.id, a.pzn, a.mid FROM PHOENIX.HOSPITAL_MEDICAMENT_INFO a 
           INNER JOIN 
                (SELECT mid, MAX(id) maxid FROM PHOENIX.HOSPITAL_MEDICAMENT_INFO GROUP BY mid) b 
                    ON a.id = b.maxid
       ) info --Medikamenteninfo um PZN zu erhalten
           ON info.MID = m.MID
    WHERE m.MID = ${midCounter}
    AND m.recent = TRUE
    AND (i.INGREDIENT_TYPE IS NULL OR i.INGREDIENT_TYPE = 0 OR i.INGREDIENT_TYPE = 2 OR i.INGREDIENT_TYPE = 4)
  )
ORDER BY "abdataInfos" DESC, "Typ", "Key_Sto", "Zahl", "Einheit", "Stoff_Typ"