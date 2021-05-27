select
	ma.mid as "ma_mid",
	ma.status as "ma_status",
	mo.id as "mo_id",
	mo.total_volume as "mo_total_volume"
from
	${db_MeonaTestSchema}.medication_application ma
	inner join ${db_MeonaTestSchema}.abstract_application aa on 
		aa.id = ma.id and 
		aa.recent = 1 and	 
		aa.deleted = false
	inner join phoenix.medication_order mo on
		mo.id = aa.main_order_id
	where ma.mid = -1
	and aa.application_by in ('haverka', 'studie')
order by
	aa.id desc