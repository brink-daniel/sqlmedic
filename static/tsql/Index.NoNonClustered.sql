/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Nov 2016</Date>
	<Title>No non-clustered indexes</Title>
	<Description>Tables without indexes will perform poorly when queries.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>minute</Frequency>
	<Category>Performance</Category>
	<Foreachdb>true</Foreachdb>
	<store></store>
	<Window>00:00 - 23:59</Window>
	<Days>M0WTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


select
	db_name() as [database],
	t.name as [table],
	sum(iif(i.type_desc = 'CLUSTERED', 1, 0)) as [clustered],
	sum(iif(i.type_desc = 'NONCLUSTERED', 1, 0)) as [non-clustered]

from 
	sys.tables as t

	inner join sys.indexes as i
	on t.object_id = i.object_id

where db_name() not in ('master', 'tempdb', 'msdb', 'model', 'RedGateMonitor')

group by 
	t.name

having
	sum(iif(i.type_desc = 'NONCLUSTERED', 1, 0)) = 0