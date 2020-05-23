/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>20 Nov 2013</Date>
	<Title>Index fragmentation</Title>
	<Description>Fragmented indexes will result in slow query performance. Only indexes that have a page count of more than 500 and are in active use are included in this check. Indexes are deemed to be in active use if there were more than 100 seeks, scans or lookups on the index since the last server reboot.</Description>
	<Pass>No indexes were found to be fragmented more than 30%.</Pass>	
	<Fail>{x} index(es) were found to be fragmented more than 30%.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Index</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted



declare @dbid int
select 
	@dbid = db_id()

select 
	db_name() as [Database],
	object_name(stat.[object_id]) as [Table],
	i.[name] as [Index],
	convert(decimal(26, 2), stat.avg_fragmentation_in_percent) as [Frag. percent],
	u.user_seeks as [Seeks],
	u.user_scans as [Scans],
	u.user_lookups as [Lookups],
	stat.page_count as [Page count]

from    
	sys.dm_db_index_physical_stats(@dbid, null, null, null, 'limited') as stat

	inner join sys.indexes as i
	on stat.[object_id] = i.[object_id]
		and stat.index_id = i.index_id
		and i.[name] is not null --exclude heaps

	inner join sys.dm_db_index_usage_stats as u
	on stat.database_id = u.database_id
		and stat.[object_id] = u.[object_id]
		and stat.index_id = u.index_id
		and (
			u.user_seeks > 100
			or u.user_scans > 100
			or u.user_lookups > 100
		)
			
where
	objectproperty(stat.[object_id],'IsUserTable') = 1
	and stat.avg_fragmentation_in_percent > 30
	and stat.page_count > 1000
	and db_name() not in ('master', 'msdb', 'model', 'tempdb')




