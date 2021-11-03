-- Strategisches Vorgehen bei Datenextraktion
-- Idee: Extraktion aller Medikationsapplikation für definierten Zeitraum (start/end date) 
-- 	 Query vermeidet joins mit Tabellen, welche über MID assoziert sind 
-- 	 Informationen zu Medikamenten werden in gesonderten Queries ausgelagert. 

-- Query 1 
-- Extraktion aller Medikationsapplikation für definierten Zeitraum (start/end date) 
-- Relevante Tabellen: 	- abstract_application 
--			- medication_application 
--			- abstract_order 
--			- medication_order 
-- 			- medication_order_medicament 

SELECT 
   ma.id,
   aa.patient_id,
   aa.actual_date_time,
   ao.order_text,
   ao.paused,
   ma.apply_date,
   ma.actual_dose,
   ma.perfusor_volume,
   mo.dosage_type,
   CASE WHEN mom.MID IS NULL THEN mo.MID -- die mid ist entweder in mo oder mom vorhanden
   ELSE mom.MID				 -- durch diese Fallunterscheidung gibt es nur eine
   END AS mid 				 -- Spalte mit mid im ResultSet
FROM phoenix.abstract_application AS aa
   INNER JOIN phoenix.medication_application AS ma ON aa.id = ma.id
   INNER JOIN phoenix.abstract_order AS ao ON aa.main_order_id = ao.id
   INNER JOIN phoenix.medication_order AS mo ON ao.id = mo.id
   LEFT JOIN phoenix.medication_order_medicament AS mom ON mo.id = mom.medication_order
WHERE aa.deleted IS FALSE
AND aa.recent IS TRUE
AND ao.order_type < 2
AND ma.id IN (SELECT ma.id 				-- Filtern der infrage kommenden ma.id an dieser Stelle
	      FROM PHOENIX.MEDICATION_APPLICATION ma    -- steigert die Performance der Query erheblich
	      WHERE ma.status <> 4
              AND ma.apply_date BETWEEN :start AND :end)
	      
	      
-- Informationen zum Medikament
-- Query 1 liefert unter anderem eine Liste an MIDs (Mehrfachnennung einzelner MID möglich). 
-- Diese MIDs (ohne Mehrfachnennung) werden genutzt um Informationen zu den Medikamenten 
-- abzufragen und nachgeschaltet den Medikationsapplikationen zugeordnet. Jedes Medikament
-- enthält eine VID, welche auf die dazugehörigen Wirkstoffe (Ingredient) verweist.
-- Abfrage der Ingredients nicht über join, sondern über seperate Query (siehe Query 3).

-- Query 2
-- Relevante Tabellen: 	- medicament
-- maxDB bedingt ist die Größe der Liste der MIDs auf 1000 Elemente zu beschränken. 

SELECT
   med.mid,
   med.active,
   med.sortname,
   med.reference_unit, 
   med.tradename,
   med.atc,
   med.pharmaceutical_form,
   med.vid
FROM phoenix.medicament med 
WHERE med.recent = TRUE
AND med.mid IN (:mids)


-- Abfrage zur dem Medikament zugehörigen Wirkstoffen
-- Analog zu Query 2. Ingredients müssen über ing.id (vid) im Code
-- dem jeweiligen Medikament zugeordnet werden. Ein Medikament 
-- enthält somit eine Liste an Ingredients.

-- Query 3
-- Relevante Tabellen: 	- ingredient
-- maxDB bedingt ist die Größe der Liste der VIDs auf 1000 Elemente zu beschränken. 
SELECT 
   ing.medicament,
   ing.name,
   ing.amount,
   ing.unit,
   ing.id,
   ing.ingredient_type 
FROM phoenix.ingredient AS ing
WHERE ing.medicament IN (:vids)

-- Informationen zum Medikament
-- Analog zu Query 2 mit dem Unterschied dass die Information zum Medikament
-- über die Hausliste abgerufen werden. Die dazugehörige Tabelle enthält
-- unter anderem die PZN (>80% der Fälle)

-- Query 4
-- Relevante Tabellen: 	- hospital_medicament_info
-- maxDB bedingt ist die Größe der Liste der MIDs auf 1000 Elemente zu beschränken. 
SELECT
   hmi.mid,
   hmi.name,
   hmi.pzn,
   hmi.formulary_medicament
FROM phoenix.hospital_medicament_info hmi
WHERE hmi.mid IN (:mids)
