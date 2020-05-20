/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jan 2014</Date>
	<Title>Unused indexes</Title>
	<Description>Indexes which are being maintained, but have not been used by any query since the last server reboot should be reviewed. These indexes may be harming the system performance as they have to be updated each time an insert, update or delete is performed on the table.</Description>
	<Pass>No unused indexes found.</Pass>	
	<Fail>{x} unused indexes found.</Fail>
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

if (select top 1 coalesce(create_date,getdate()) from sys.databases where name = 'tempdb') < dateadd(week, -1, getdate())
begin

	create table #indexes (
		database_id int,
		[object_id] int,
		index_id int,
		name varchar(250),
		type_desc varchar(250),
		[Table] varchar(250)
	)


	exec sp_msforeachdb '
		use [?]
	
		insert into #indexes (database_id, [object_id], index_id, name, type_desc, [Table])
		select 
			db_id() as database_id, 
			[object_id], 
			index_id, 
			name,
			type_desc, 
			object_name([object_id]) as [Table]

		from [?].sys.indexes
		where 
			name is not null
			
		option (recompile)		
	
	'




	select 
		db_name(u.database_id) as [Database],
		i.[Table],
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

	where
		u.user_seeks = 0
		and u.user_scans = 0
		and u.user_lookups = 0	
		and db_name(u.database_id) not in ('master', 'msdb', 'tempdb', 'model', 'ReportServer', 'ReportServerTempDB')
		and i.name is not null
		--and u.user_updates > 500
	
	order by
		u.user_updates desc,
		db_name(u.database_id),
		i.[Table],
		i.name



	drop table #indexes

end