/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Auto statistics update</Title>
	<Description>Statistics are required by the Query Optimiser to select the best execution plan. Inefficient execution plans will be created and used if no statistics are available or the statistics are outdated, resulting in slow query performance.</Description>
	<Pass>All databases are correctly configured to automatically create and update statistics.</Pass>	
	<Fail>{x} database(s) are not correctly configured for automatic statistic creation and update.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	name as [Database], 	
	is_auto_create_stats_on as [Is auto create stats on],
	is_auto_update_stats_on as [Is auto update stats on]
	
from sys.databases 
where 
	(
		is_auto_create_stats_on = 0
		or is_auto_update_stats_on = 0
	)
	and state_desc = 'ONLINE'
order by
	name