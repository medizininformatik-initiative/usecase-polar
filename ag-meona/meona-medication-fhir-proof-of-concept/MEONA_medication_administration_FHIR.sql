select
	distinct aa.id,
	aa.actual_date_time as "effectivedatetime",
	aa.patient_id as "subject",
	aa.actual_duration,
	aa.comment,
	case
		when ma.mid = -1 then mom.mid
		else ma.mid 
	end as "medication.identifier",
	ma.route_of_application as "dosage.route",
	ma.actual_bolus_value as "ma.actual_bolus_value",
	ma.actual_dose as "ma.actual_dose",
	ma.perfusor_appl_type as "ma.perfusor_appl_type",
	ma.perfusor_volume as "ma.perfusor_volume",
	ma.status as "ma.status",
	mo.dosage_ingredient_unit as "mo.dosage_ingredient_unit",
	mo.id as "mo.id",
	mo.dosage_type as "mo.dosage_type",
	mo.total_volume as "mo.total_volume",
	mom.amount as "mom.amount",
	m.reference_value as "m.reference_value",
	m.sortname,	
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
left join phoenix.medicament m on
	m.mid = ma.mid
left join phoenix.ingredient i2 on
	i2.ID = mo.dosage_ingredient_id 
left join phoenix.medicament_equivalent me2 on
	me2.id = mo.dosage_ingredient_id	
where
	deleted = false
	and aa.recent = true
	and aa.id > 1003434011
--    and m.recent = true
	and aa.application_by in ('haverka', 'studie')
	and ma.mid <> 0
order by
	aa.id desc