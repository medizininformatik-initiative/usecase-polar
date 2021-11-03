-- Mischung: wenn mehr als 1 Eintrag in Spalte Medication_order_medicament.medication_order
-- Zur Definition erforderlich: Tabellen Medication_order_medicament und Medication_order
-- weitere Tabellen dazu für mehr Bedingungen (z.B. nur verabreichte Mischung usw.)
-- in Freiburg nicht über dieses lange SQL programmiert, sondern als separate Abfragen
SELECT distinct
    --ma.status as "ma_status", -- zur Kontrolle dazu falls man Mischungen ausschliessen will, die nicht verabreicht wurden
    mo.id as "mo_id",   -- FHIR Medication: als identifier
    mom.mid as "mom_mid",  -- FHIR Medication: ingredient.itemReference.reference  
    mom.amount as "mom_amount", -- FHIR Medication: ingredient.strenght.numerator.value
    mo.total_volume as "mo_total_volume" -- FHIR Medication: ingredient.strenght.denominator.value
from
      phoenix.medication_order_medicament mom
        inner join phoenix.medication_order mo on
		   mo.id = mom.medication_order
	inner join phoenix.abstract_application aa on -- für Testdatensatz
           mo.id = aa.main_order_id
	inner join phoenix.medication_application ma on -- falls Info von ma gebraucht wird
		   aa.id = ma.id and -- für Testdatensatz
		   aa.recent = 1 and -- für Testdatensatz 
		   aa.deleted = false -- für Testdatensatz	 
        inner join (SELECT count(medication_order), medication_order   --  > 1 Medikament je Verordnung
                     FROM PHOENIX.MEDICATION_ORDER_MEDICAMENT
                     group by medication_order 
                     HAVING count(medication_order)>1) mehr_als_ein_medikament on
            mehr_als_ein_medikament.medication_order =mom.medication_order
    where --ma.status <> 4 and ma.status <> 3 -- Ausschluss: nicht verabreicht, nicht gestellt
	--AND 
	aa.id >=1003453917 and aa.id <=1003453992 -- für Testdatensatz
   ORDER BY mo.id -- für Testausgabe