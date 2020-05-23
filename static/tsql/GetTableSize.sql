/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>16 Feb 2015</Date>
	<Title>Table row count, data size and index size</Title>
	<Description>Find the table row count, data size and index size for all tables.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted



select
	db_name() as [Database],
	s.name as [Schema], 
	t.name as [Table],
	p.[rows] as [Row count],
	cast((8 * sum(case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3)) as [Data space (MB)],
	cast((8 * sum(a.used_pages - case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3)) as [Index space (MB)],
	cast(
		((8 * sum(case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0)
		+ ((8 * sum(a.used_pages - case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0)	
	as decimal(26,3)) as [Total space (MB)],
	max(u.last_user_seek) as [Last user seek],
	max(u.last_user_scan) as [Last user scan],
	max(u.last_user_lookup) as [Last user lookup],
	max(u.last_user_update) as [Last user update]

from 
	sys.indexes as i

	inner join sys.partitions as p
	on i.[object_id] = p.[object_id] 
		and i.index_id = p.index_id

	inner join sys.allocation_units as a
	on a.container_id = p.partition_id

	inner join sys.tables as t
	on i.[object_id] = t.object_id
	
	inner join sys.schemas as s
	on t.[schema_id] = s.[schema_id]
	
	left join sys.dm_db_index_usage_stats as u
	on i.[object_id] = u.[object_id] 
		and i.index_id = u.index_id
		and u.database_id = db_id()

group by 
	s.name,
	t.name,
	p.[rows]

order by
	[Total space (MB)] desc
	
	
