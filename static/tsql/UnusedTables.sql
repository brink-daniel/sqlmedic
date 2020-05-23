/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>23 Dec 2013</Date>
	<Title>Unused tables</Title>
	<Description>Unused tables can take up large mounts of hard drive space and make database backups unnecessarily larger. This check is being done based on the index usage statistics of each table, thus this check will exclude tables without any indexes. Also note that the index usage statistic are reset when your SQL instance is restarted, thus this check will only identify tables that has been accesses since the last restart of your SQL instance, but not accessed (read) in more than a month.</Description>
	<Pass>No tables found which have not been accessed within the last month.</Pass>	
	<Fail>{x} table(s) found which have not been accessed within the last month.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

if (select top 1 coalesce(create_date,getdate()) from sys.databases where name = 'tempdb') < dateadd(month, -1, getdate())
begin


	create table #tables (
		[Database] varchar(250),
		[Table] varchar(250),
		[Last user lookup] datetime,
		[Last user scan] datetime,
		[Last user seek] datetime
	)

	if (select top 1 coalesce(create_date,getdate()) from sys.databases where name = 'tempdb') < dateadd(month, -1, getdate())
	begin

		exec sp_msforeachdb '

			use [?]
	
			if ''?'' not in (''master'', ''tempdb'', ''msdb'', ''model'')
			begin

				insert into #tables ([Database],[Table],[Last user lookup],[Last user scan],[Last user seek])
				select 
					db_name(i.database_id) as [Database],
					object_name(i.[object_id]) as [Table],
					max(i.last_user_lookup) as [Last user lookup],
					max(i.last_user_scan) as [Last user scan],
					max(i.last_user_seek) as [Last user seek]
			
				from sys.dm_db_index_usage_stats as i
				where i.[database_id] = db_id()
				group by
					i.[database_id], 
					i.[object_id]
			
				having
					(
						max(i.last_user_lookup) is null
						and max(i.last_user_scan) is null
						and max(i.last_user_seek) is null
					)
					or 
					(
						isnull(max(i.last_user_lookup), dateadd(month, -1, getdate())) <= dateadd(month, -1, getdate())
						and isnull(max(i.last_user_scan), dateadd(month, -1, getdate())) <= dateadd(month, -1, getdate())
						and isnull(max(i.last_user_seek), dateadd(month, -1, getdate())) <= dateadd(month, -1, getdate())
					)
			

				order by
					[Last user lookup],
					[Last user scan],
					[Last user seek]


				option (recompile)
		
	
			end
		'

	end

	select 
		[Database],
		[Table],
		[Last user lookup],
		[Last user scan],
		[Last user seek]
	from #tables

	order by
		[Database],
		[Last user lookup],
		[Last user scan],
		[Last user seek]


	drop table #tables


end