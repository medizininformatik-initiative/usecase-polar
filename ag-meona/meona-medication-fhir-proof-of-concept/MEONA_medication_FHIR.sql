select
	distinct aa.id,
	actual_date_time as "effectivedatetime",
	patient_id as "subject",
	ma.route_of_application as "dosage.route",
	i.name as "ingredient.name",
	i.ingredient_type as "ingredient.type",
	i.amount as "ingredient.dosage.value",
	i.unit as "ingredient.dosage.unit",
	ma.actual_dose as "ma.actual_dose", 
	ma.perfusor_appl_type as "ma.perfusor_appl_type",
	ma.perfusor_volume as "ma.perfusor_volume",
	ma.site_of_application as "ma.site_of_application",
	ma.status as "ma.status",
 	mo.bolus_value as "mo.bolus_value",
	mo.bolus_unit as "mo.bolus_unit",
	mo.dosage_ingredient_unit as "mo.dosage_ingredient_unit",
	mo.dosage_ingredient_id as "mo.dosage_ingredient_id",
	mo.dosage_type as "mo.dosage_type",
	mo.total_volume as "mo.total_volume",
	mom.dosage_ingredient_unit as "mom.dosage_ingredient_unit",
	mom.dosage_ingredient_id as "mom.dosage_ingredient_id",
	mom.volume as "mom.volume",
	mom.volume_unit as "mom.volume_unit",
	mom.dosage_type as "mom.dosage_type",
	i.substance_id as "i.substance_id",
	m.pharmaceutical_form as "m.pharmaceutical_form",
	m.reference_unit as "m.reference_unit",
	m.reference_value as "m.reference_value",
	me.id as "me.id",
	me.name as "me.name",
	me.mid as "me.mid",
	me.equivalent_type as "me.equivalent_type",
	me.amount as "me.amount",
	me.unit as "me.unit",
	m.sortname as "m.sortname",
	m.tradename as "m.tradename",
	m.unit_dose_name as "m.unit_dose_names",
	i2.amount as "i.amount.lookup",
	me2.amount "me.amount.lookup"
from
	phoenix.abstract_application aa
join phoenix.medication_application ma on
	aa.id = ma.id
left join phoenix.medication_order mo on
	mo.id = aa.main_order_id
left join phoenix.medication_order_medicament mom on
	mom.medication_order = aa.main_order_id
left join phoenix.ingredient i on
	i.medicament = ma.mid
left join phoenix.medicament m on
	m.mid = ma.mid
left join phoenix.abda_are_med_object fam on
	m.source_id = fam.key_fam
left join phoenix.medicament_equivalent me on
	me.mid = ma.mid
-- ...ingredient.dosage...	
-- on mo.dosage_ingredient_id = ingredient.id
left join phoenix.ingredient i2 on
	i2.ID = mo.dosage_ingredient_id 
-- ...medicament_equivalent.amount...
-- on mo.dosage_ingredient_id = me.ID
left join phoenix.medicament_equivalent me2 on
	me2.id = mo.dosage_ingredient_id	
where
	deleted = false
	and aa.recent = true
	and aa.id > 1003434011
	and m.recent = true
	and aa.application_by in ('haverka', 'studie')
order by
	aa.id desc
