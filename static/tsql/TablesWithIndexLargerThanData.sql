/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>04 Mar 2014</Date>
	<Title>Large indexes</Title>
	<Description>Indexes should be created to enhance access to the raw data stored in a table. Creating indexes which are larger than the actual raw data could indicate poor database design, but will also result in performance issues as these large indexes will have to be maintained.</Description>
	<Pass>No indexes found to be larger than the raw underlying data.</Pass>	
	<Fail>{x} table(s) found with indexes requiring more storage space than the actual data.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Index</Category>
	<Foreachdb>false</Foreachdb>
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
	cast((8 * sum(a.used_pages - case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3)) as [Index space (MB)]

from 
	sys.indexes as i

	inner join sys.partitions as p
	ON p.object_id = i.object_id and p.index_id = i.index_id

	inner join sys.allocation_units as a
	ON a.container_id = p.partition_id

	inner join sys.tables as t
	on i.[object_id] = t.object_id
	
	inner join sys.schemas as s
	on s.[schema_id] = t.[schema_id]

group by 
	s.name,
	t.name,
	p.[rows]

having
	cast((8 * sum(a.used_pages - case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3))
	> cast((8 * sum(case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3))
	and cast((8 * sum(case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3)) > 1
	










