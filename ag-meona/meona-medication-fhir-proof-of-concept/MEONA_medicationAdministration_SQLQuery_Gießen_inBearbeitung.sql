--nicht beendet
SELECT 
    aa.ID, 
    ma.MID, 
    aa.PATIENT_ID, 
    aa.ACTUAL_DATE_TIME, 
    aa.ACTUAL_DURATION, 
    mo.DOSAGE_TYPE, 
    ma.ROUTE_OF_APPLICATION, 
    mom.AMOUNT AS "mom_amount", 
		ma.ACTUAL_BOLUS_VALUE, 
		mo.BOLUS_UNIT, 
		mo.DOSAGE_INGREDIENT_UNIT,
		ma.ACTUAL_DOSE, 
		m.UNIT_DOSE_NAME, 
		m.PHARMACEUTICAL_FORM, 
		ma.status, 
		aa.comment,
		m.REFERENCE_VALUE, 
		m.REFERENCE_UNIT, 
		me.AMOUNT AS "me_amount", 
		i.AMOUNT AS "i_amount"
FROM 
    PHOENIX.MEDICATION_APPLICATION ma 
LEFT JOIN PHOENIX.ABSTRACT_APPLICATION aa 
    ON ma.id = aa.ID 
LEFT JOIN PHOENIX.MEDICAMENT m 
    ON ma.MID = m.MID 
LEFT JOIN PHOENIX.MEDICATION_ORDER mo 
    ON aa.MAIN_ORDER_ID = mo.ID 
LEFT JOIN PHOENIX.MEDICATION_ORDER_MEDICAMENT mom 
    ON mo.ID = mom.MEDICATION_ORDER 
LEFT JOIN PHOENIX.MEDICAMENT_EQUIVALENT me 
    ON mo.DOSAGE_INGREDIENT_ID = me.ID 
LEFT JOIN PHOENIX.INGREDIENT i 
    ON mo.DOSAGE_INGREDIENT_ID = i.ID 
WHERE aa.APPLICATION_TYPE = 1 --Medikation
AND aa.RECENT = TRUE
AND m.RECENT = TRUE
AND aa.DELETED = FALSE 
AND ma.MID != '-1' --Einzelmedikation
AND ma.STATUS IN ('1', '2', '4')    --"in-progress", "completed", "not-done"
AND ma.ACTUAL_BOLUS_VALUE IS NULL   
AND aa.ACTUAL_DURATION = '-1'       
AND ma.id BETWEEN ${CounterStart} AND ${CounterEnd}