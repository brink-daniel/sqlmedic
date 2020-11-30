/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>30 Nov 2020</Date>
	<Title>Maintenance Plan History</Title>
	<Description>Maintenance Plans are executed via SQL Agent jobs, but additional history information is stored in MSDB. The SQL Agent Job may report as being successful, while the actual Maintenance Plan failed.</Description>
	<Pass></Pass>
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Administration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



select top 100
	p.name
	, d.start_time
	, d.end_time
	, d.command
	, d.error_message
	, d.succeeded
		
from 
	msdb.dbo.sysmaintplan_plans as p

	left join msdb.dbo.sysmaintplan_log as l
	on p.id = l.plan_id

	left join msdb.dbo.sysmaintplan_logdetail as d
	on l.task_detail_id = d.task_detail_id

order by d.start_time desc


