-- SQL für Medikation, die in Stück zu einem bestimmten Zeitpunkt gegeben wird (MEDICATION_APPLICATION.MID <> -1 und MEDICATION_ORDER.MID <> -1)
-- d.h. hier keine Mischungen und Infusionen
-- Filterung auf deleted false, bzw. recent true und Verabreichungsstatus passiert in der ETL Strecke
WITH MO_ME_ING AS (
    SELECT MO.ID                     AS ID_MO,
           MO.DOSAGE_INGREDIENT_ID   AS DOSAGE_INGREDIENT_ID_MO,
           MO.DOSAGE_INGREDIENT_UNIT AS DOSAGE_INGREDIENT_UNIT_MO,
           MO.DOSAGE_TYPE            AS DOSAGE_TYPE_MO,

           MO.MID                    AS MID_MO,
           ING_MO.AMOUNT             AS AMOUNT_ING_MO,
           ING_MO.INGREDIENT_TYPE    AS INGREDIENT_TYPE_ING_MO,
           ING_MO.NAME               AS NAME_ING_MO,
           ING_MO.UNIT               AS UNIT_ING_MO,

           ME_MO.AMOUNT              AS AMOUNT_ME_MO,
           ME_MO.EQUIVALENT_TYPE     AS EQUIVALENT_TYPE_ME_MO,
           ME_MO.NAME                AS NAME_ME_MO,
           ME_MO.UNIT                AS UNIT_ME_MO

    FROM STG_MEONA.MEDICATION_ORDER MO
             LEFT JOIN STG_MEONA.INGREDIENT ING_MO ON MO.DOSAGE_INGREDIENT_ID = ING_MO.ID
             LEFT JOIN STG_MEONA.MEDICAMENT_EQUIVALENT ME_MO ON MO.DOSAGE_INGREDIENT_ID = ME_MO.ID
),

     MED_ATC_HOSMED AS (
         SELECT MED.MID                 AS MID_MED_MA,
                MED.ATC                 AS ATC_MED_MA,
                MED.PHARMACEUTICAL_FORM AS PHARMACEUTICAL_FORM_MED_MA,
                MED.REFERENCE_UNIT      AS REFERENCE_UNIT_MED_MA,
                MED.REFERENCE_VALUE     AS REFERENCE_VALUE_MED_MA,
                MED.TRADENAME           AS TRADENAME_MED_MA,
                MED.UNIT_DOSE_NAME      AS UNIT_DOSE_NAME_MED_MA,

                HOSMEDINF.NAME          AS NAME_HOSPITAL_MED_INFO,
                HOSMEDINF.PZN           AS PZN_HOSPITAL_MED_INFO
         FROM STG_MEONA.MEDICAMENT MED
                  LEFT JOIN STG_MEONA.HOSPITAL_MEDICAMENT_INFO HOSMEDINF
                            ON MED.MID = HOSMEDINF.MID
     ),

     MA_FILTER AS (
         SELECT MA.ID                   AS ID_MA_FILTER,
                MA.ACTUAL_DOSE          AS ACTUAL_DOSE_MA_FILTER,
                MA.MID                  AS MID_MA_FILTER,
                MA.ROUTE_OF_APPLICATION AS ROUTE_OF_APPLICATION_MA_FILTER,
                MA.SITE_OF_APPLICATION  AS SITE_OF_APPLICATION_MA_FILTER,
                MA.STATUS               AS STATUS_MA_FILTER
         FROM STG_MEONA.MEDICATION_APPLICATION MA
         WHERE MA.ACTUAL_DOSE < 999999999999 --wg. einem für unser ETL zu großem Wert in den Daten
           and MA.MID <> -1
     ),

     AA_MA AS (
         SELECT AA.ID                                    AS ID_AA,
                AA.ACTUAL_DATE_TIME                      AS ACTUAL_DATE_TIME_AA,
                AA."COMMENT"                             AS COMMENT_AA,
                CREATION_DATE,
                AA.DELETED                               AS DELETED_AA,
                AA.MAIN_APPLICATION_ID                   AS MAIN_APPLICATION_ID_AA,
                AA.MAIN_ORDER_ID                         AS MAIN_ORDER_ID_AA,
                AA.PATIENT_ID                            AS PATIENT_ID_AA,
                AA.RECENT                                AS RECENT_AA,
                AA.VERSION                               AS VERSION_AA,

                ACTUAL_DOSE_MA_FILTER                    AS ACTUAL_DOSE_MA,
                MA_FILTER.MID_MA_FILTER                  AS MID_MA,
                MA_FILTER.ROUTE_OF_APPLICATION_MA_FILTER AS ROUTE_OF_APPLICATION_MA,
                MA_FILTER.SITE_OF_APPLICATION_MA_FILTER  AS SITE_OF_APPLICATION_MA,
                MA_FILTER.STATUS_MA_FILTER               AS STATUS_MA

         FROM STG_MEONA.ABSTRACT_APPLICATION_MEDICATION AA
                  JOIN MA_FILTER ON AA.ID = MA_FILTER.ID_MA_FILTER
     )

SELECT *
FROM AA_MA
         LEFT JOIN MED_ATC_HOSMED ON AA_MA.MID_MA = MED_ATC_HOSMED.MID_MED_MA
         LEFT JOIN MO_ME_ING ON AA_MA.MAIN_ORDER_ID_AA = MO_ME_ING.ID_MO
WHERE MID_MO <> -1
ORDER BY CREATION_DATE ASC
