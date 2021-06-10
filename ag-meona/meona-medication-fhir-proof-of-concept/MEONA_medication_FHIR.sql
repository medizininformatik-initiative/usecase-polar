(
	select distinct 
		aa.id as "aa.id"
		, m.atc as "m.atc"
		, m.pharmaceutical_form as "m.pharmaceutical_form"
	    , m.sortname as "m.sortname"
		, m.tradename as "m.tradename"
		, i.name as "ingredient.name"
		, i.amount as "ingredient.dosage.value"
		, i.unit as "ingredient.dosage.unit"
		, i.ingredient_type as "ingredient.type"
		, i.sequence_number as "i.sequence_number"
		, m.reference_value as "m.reference_value"
		, m.reference_unit as "m.reference_unit"
		, m.mid as "m.mid"
		, i.substance_id as "i.substance_id"
		, m.unit_dose_name as "m.unit_dose_names"
	from
		phoenix.medicament m
	join phoenix.medication_application ma on
		m.mid = ma.mid
	join phoenix.abstract_application aa on
		aa.id = ma.id
	join phoenix.ingredient i on
		i.medicament = m.mid	
	where
		aa.deleted = false
		and aa.recent = true
		and aa.id > 1003434011
		and m.recent = true
		and aa.application_by in ('haverka', 'studie')
	)
union 
(
	select distinct 
		aa.id as "aa.id"
		, m.atc as "m.atc"
		, m.pharmaceutical_form as "m.pharmaceutical_form"
	    , m.sortname as "m.sortname"
		, m.tradename as "m.tradename"
		, i.name as "ingredient.name"
		, i.amount as "ingredient.dosage.value"
		, i.unit as "ingredient.dosage.unit"
		, i.ingredient_type as "ingredient.type"
		, i.sequence_number as "i.sequence_number"
		, m.reference_value as "m.reference_value"
		, m.reference_unit as "m.reference_unit"
		, m.mid as "m.mid"
		, i.substance_id as "i.substance_id"
		, m.unit_dose_name as "m.unit_dose_names"
	from
		phoenix.medicament m
	join phoenix.medication_order_medicament mom on
		mom.mid = m.mid
	join phoenix.abstract_application aa on
		mom.medication_order = aa.main_order_id 
	join phoenix.ingredient i on
		i.medicament = m.mid	
	where
		aa.deleted = false
		and aa.recent = true
		and aa.id > 1003434011
		and m.recent = true
		and aa.application_by in ('haverka', 'studie')
)	
order by
	aa.id desc