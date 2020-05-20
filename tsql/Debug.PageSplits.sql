/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>16 Dec 2016</Date>
	<Title>Get page splits per index</Title>
	<Description>Excessive page splits result in index fragmentation and increased IO. Page splits are normal and occur when data is added to an existing page where there is insufficient free space on the page. The page is split into two separate 8K pages to create free space. Reducing the index fill factor may help to alleviate the page splitting, but will increase the size of the index. The actual number of page splits is meaningless. The goal here is to help you identify indexes that could possibly be improved, for example by selecting keys that ensure inserts are at the end of the index or setting a more appropriate fill factor for your system's typical workload. Also, remember that index maintenance activities will reset that page split number and that page splits are not always a bad thing. High page splits may simply be an indication of a high rate of data ingest.</Description>
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


select top 20
	db_name() as [database],
	t.name as [table],
	i.name as [index],
	isnull(nullif(i.fill_factor,0), 100) as [fill factor],
	s.leaf_allocation_count as [page splits],
	p.[rows],
	cast((8 * sum(case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3)) as [data (mb)],
	cast((8 * sum(a.used_pages - case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0 as decimal(26,3)) as [index (mb)],
	cast(
		((8 * sum(case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0)
		+ ((8 * sum(a.used_pages - case when a.type <> 1 then a.used_pages when p.index_id < 2 then a.data_pages else 0 end)) / 1024.0)	
	as decimal(26,3)) as [total (mb)]

from 
	sys.tables as t

	inner join sys.indexes as i
	on t.object_id = i.object_id
		
	inner join (
		select 			
			object_id, 
			index_id, 
			leaf_allocation_count 
		from sys.dm_db_index_operational_stats(db_id(), null, null, null)
		where leaf_allocation_count > 0
	) as s
	on t.object_id = s.object_id
		and i.index_id = s.index_id


	inner join sys.partitions as p
	on i.[object_id] = p.[object_id] 
		and i.index_id = p.index_id

	inner join sys.allocation_units as a
	on p.partition_id = a.container_id

	left join sys.dm_db_index_usage_stats as u
	on i.[object_id] = u.[object_id] 
		and i.index_id = u.index_id
		and u.database_id = db_id()

group by
	t.name,
	i.name,
	i.fill_factor,
	s.leaf_allocation_count,
	p.[rows]
	
order by [page splits] desc