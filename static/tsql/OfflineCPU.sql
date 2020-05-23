/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>28 Oct 2015</Date>
	<Title>CPU Core not used by SQL</Title>
	<Description>Microsoft limits the amount of cores used by SQL Server through license agreements. Upgrading your SQL license will allow SQL Server to see and use more CPU cores and thus perform better.</Description>
	<Pass>All core are seen and used by SQL</Pass>	
	<Fail>{x} CPU cores are not in use.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>Weekly</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted

if (select cpu_count from sys.dm_os_sys_info) != (select 
	count(*)
from sys.dm_os_schedulers 
where 
	[status] = 'VISIBLE ONLINE'
	and scheduler_id = cpu_id
)
begin

	select 
		scheduler_id,
		cpu_id,
		[status],
		is_online
	from sys.dm_os_schedulers 
	where 
		scheduler_id = cpu_id
		and [status] != 'VISIBLE ONLINE'
	
end
