
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Indexes</Title>
	<Description>Index usage</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_Index</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


create table #indexes (
	database_id int,
	[object_id] int,
	index_id int,
	name varchar(250),
	type_desc varchar(250)
)


exec sp_msforeachdb '
	use [?]
			
	insert into #indexes (database_id, [object_id], index_id, name, type_desc)
	select 
		db_id() as database_id, 
		[object_id], 
		index_id, 
		name,
		type_desc
	from sys.indexes		

	option (recompile)
			
'


select
	getdate() as [TimeStamp],	
	@@servername as [Server],
	db_name(u.database_id) as [Database],
	object_name(u.[object_id], u.database_id) as [Table],
	i.name as [Index], 
	i.type_desc as [Type],	
	u.user_seeks as [Seeks],
	u.user_scans as [Scans],
	u.user_lookups as [Lookups],
	u.user_updates as [Updates]

from 
	sys.dm_db_index_usage_stats as u
			
	left join #indexes as i
	on u.database_id = i.database_id
		and u.[object_id] = i.[object_id]
		and u.index_id = i.index_id

where db_name(u.database_id) not in ('master', 'msdb', 'tempdb', 'model', 'ReportServer', 'ReportServerTempDB')
			
order by
	db_name(u.database_id),
	object_name(u.[object_id], u.database_id),
	i.name

drop table #indexes		