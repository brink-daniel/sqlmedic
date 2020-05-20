/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Nov 2016</Date>
	<Title>Extended events</Title>
	<Description>Log information about all stored procedures and batches executed.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Example</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



create procedure spGetLastSPExecutions

@intDuration int = 10,
@vchDatabases varchar(max), -- 'Database1,Database2,Database3'
@vchExcludeObjects varchar(max), -- 'spOne,spTwo,spThree'
@bitNoiseFilter bit = 1,
@bitIncludeRPC bit = 1,
@bitIncludeSQLBatch bit = 0,
@vchExcludeDatabases varchar(max) = '' -- 'Database5,Database6'

as 

begin 

	set nocount on

	declare @xsession varchar(250)
	set @xsession = 'log_stored_proc_calls'
	
	
	
	if @intDuration < 5 or @intDuration > 59
	begin			
		raiserror('Please select a duration between 5 and 59 seconds', 16, 1)
		return
	end

	
	if @bitIncludeRPC = 0 and @bitIncludeSQLBatch = 0
	begin
		raiserror('PRC and/or SQL Batch must be selected', 16, 1)
		return
	end

	create table #databases (
		database_id int
	)

	insert into #databases (database_id)
	select distinct
		d.database_id
	from 
		(
			select 
				rtrim(ltrim(split.a.value('.', 'varchar(250)'))) as name  
			from  
				(
					select cast ('<M>' + replace(@vchDatabases, ',', '</M><M>') + '</M>' as xml) as d  
     
				) as a 
			
				cross apply d.nodes ('/M') as split(a)

			where len(rtrim(ltrim(split.a.value('.', 'varchar(250)')))) >= 4
	) as x

	inner join sys.databases as d
	on x.name = d.name


	
	
	
	create table #exclude_databases (
		database_id int
	)
	
	insert into #exclude_databases (database_id)
	select distinct
		d.database_id
	from 
		(
			select 
				rtrim(ltrim(split.a.value('.', 'varchar(250)'))) as name  
			from  
				(
					select cast ('<M>' + replace(@vchExcludeDatabases, ',', '</M><M>') + '</M>' as xml) as d  
     
				) as a 
			
				cross apply d.nodes ('/M') as split(a)

			where len(rtrim(ltrim(split.a.value('.', 'varchar(250)')))) >= 4
	) as x

	inner join sys.databases as d
	on x.name = d.name
	
	
	
	
	
	
	if exists (select * from #databases)
	begin
		if not exists (select * from #databases where database_id = (select database_id from sys.databases where name = 'master'))
		and not exists (select * from #exclude_databases where database_id = (select database_id from sys.databases where name = 'master'))
		begin
			insert into #databases (database_id)
			select database_id from sys.databases where name = 'master'
		end
	end



	if exists (select * from #databases as d inner join #exclude_databases as e on d.database_id = e.database_id)
	begin
		raiserror('The same database cannot both be included and excluded from the results', 16, 1)
		return
	end




	create table #excludeObjects (
		[object_name] varchar(250)
	)


	insert into #excludeObjects ([object_name])
	select distinct
		rtrim(ltrim(split.a.value('.', 'varchar(250)'))) as [object_name]  
	from  
		(
			select cast ('<M>' + replace(@vchExcludeObjects, ',', '</M><M>') + '</M>' as xml) as d  
     
		) as a 
			
		cross apply d.nodes ('/M') as split(a)

	where len(rtrim(ltrim(split.a.value('.', 'varchar(250)')))) >= 0

	


	

	if exists (select * from sys.server_event_sessions where name = @xsession)
	begin		
		exec ('drop event session [' + @xsession + '] on server')
	end





	declare @vchDatabaseSelection nvarchar(max) = N''

	if exists (select * from #databases)
	begin
		select
			@vchDatabaseSelection += N'OR [sqlserver].[database_id]=(' + cast(database_id as nvarchar(max)) + N') '
		from #databases

		select @vchDatabaseSelection = substring(@vchDatabaseSelection, 3, len(@vchDatabaseSelection)) 
	end



	declare @vchExcludedObjects nvarchar(max) = N''

	select
		@vchExcludedObjects += N'AND [sqlserver].[not_equal_i_sql_unicode_string]([object_name],N''' + [object_name]  + N''') '	
	from #excludeObjects 



	declare @vchExcludedDatabases nvarchar(max) = N''

	select
		@vchExcludedDatabases += N'AND NOT [sqlserver].[database_id]=(' + cast(database_id as nvarchar(max)) + N') '
	from #exclude_databases 





	declare @vchNoiseFilter nvarchar(max) = N''

	if @bitNoiseFilter = 1
	begin
		set @vchNoiseFilter = N'
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N''Report Server'')	
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N''Red Gate Software - SQL Tools'')	
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N''SQL Search Indexer'')
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N''.Net SqlClient Data Provider'')
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N''Microsoft SQL Server Management Studio'')
		AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name],N''Microsoft SQL Server Management Studio - Transact- SQL IntelliSense'')
		AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N''SQLAgent%'')	
		AND NOT [sqlserver].[like_i_sql_unicode_string]([sqlserver].[client_app_name],N''SQL Monitor%'')	
		'
	end


	


	declare @vchRPC nvarchar(max) = N''

	if @bitIncludeRPC = 1
	begin
		set @vchRPC = 'ADD EVENT sqlserver.rpc_completed(
			SET collect_statement=(1)
			ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.username)
			WHERE (
				[sqlserver].[not_equal_i_sql_unicode_string]([object_name],N''sp_reset_connection'') 
				AND [sqlserver].[not_equal_i_sql_unicode_string]([object_name],N''sp_executesql'') 				 
				AND [sqlserver].[not_equal_i_sql_unicode_string]([object_name],N''spGetLastSPExecutions'')				 
				' + @vchExcludedObjects + N'
				' + @vchNoiseFilter + N'
				' + @vchExcludedDatabases + N'
				' + isnull('AND (' + nullif(@vchDatabaseSelection, '') + ')', '') + N'
			)	
		)'
	end





	declare @vchSQLBatch nvarchar(max) = N''

	if @bitIncludeSQLBatch = 1
	begin
		set @vchSQLBatch = 'ADD EVENT sqlserver.sql_batch_completed(
			SET collect_batch_text=(1)
			ACTION(sqlserver.client_app_name,sqlserver.database_id,sqlserver.username)
			WHERE (				
				NOT [sqlserver].[like_i_sql_unicode_string]([batch_text],N''use %'')
				' + @vchNoiseFilter + N'
				' + @vchExcludedDatabases + N'
				' + isnull('AND (' + nullif(@vchDatabaseSelection, '') + ')', '') + N'								
			)
		)'
	end
	


	
	declare @sql nvarchar(max)
	set @sql = '
	
		CREATE EVENT SESSION [' + @xsession + N'] ON SERVER 
		
		' + @vchRPC + N'
		
		' + case when @bitIncludeRPC = 1 and  @bitIncludeSQLBatch = 1 then N',' else N'' end + N'
		
		' + @vchSQLBatch + N' 
		

		ADD TARGET package0.ring_buffer(
			SET max_events_limit=(100),max_memory=(1024)
		)

		WITH (MAX_MEMORY=1024 KB,EVENT_RETENTION_MODE=ALLOW_MULTIPLE_EVENT_LOSS,MAX_DISPATCH_LATENCY=30 SECONDS,MAX_EVENT_SIZE=0 KB,MEMORY_PARTITION_MODE=NONE,TRACK_CAUSALITY=OFF,STARTUP_STATE=OFF)
	
	
	'
		

	begin try
		print @sql
		exec (@sql)
	end try
	begin catch				
		declare @e varchar(250) = error_message()
		raiserror('spGetLastSPExecutions: %s', 16, 1, @e) 
		return
	end catch



	if exists (select * from sys.server_event_sessions where name = @xsession)
	begin
	

		exec ('alter event session [' + @xsession + '] on server state=start')
	
		declare @delay varchar(50)
		set @delay = '00:00:' + right('00'  +cast(@intDuration as varchar(50)), 2)		
		waitfor delay @delay
	

		select
			convert(varchar(50), d.[TimeStamp], 120) as [TimeStamp], 
			d.[Database],
			d.[Statement],
			d.[Username],
			d.[Application]

		from 
			(
				select 
					convert(varchar(50), cast(dateadd(minute, datediff(minute, getutcdate(), getdate()), x.value('@timestamp', 'datetimeoffset')) as datetime), 120) as [TimeStamp], 
					db_name(x.query('.').value('(event/action[@name="database_id"]/value)[1]', 'int')) as [Database], 
					isnull(x.query('.').value('(event/data[@name="statement"]/value)[1]', 'varchar(max)'),   
					x.query('.').value('(event/data[@name="batch_text"]/value)[1]', 'varchar(max)'))  as [Statement],
					x.query('.').value('(event/action[@name="username"]/value)[1]', 'varchar(250)') as [Username], 
					x.query('.').value('(event/action[@name="client_app_name"]/value)[1]', 'varchar(250)') as [Application]
    
				from 
					(         
						select 
							cast(target_data as xml) xdoc   
						from 
							sys.dm_xe_sessions as s 

							inner join sys.dm_xe_session_targets as t 
							on t.event_session_address = s.[address] 

						where s.name = @xsession
					) as x         
         
				cross apply x.xdoc.nodes('/RingBufferTarget/event') T(x) 

			) as d

		
		order by d.[TimeStamp] desc
			

		exec ('alter event session [' + @xsession + '] on server state=stop')


	end
	else
	begin		
		raiserror('Extended event not found', 16, 1) 	
		return
	end
	
	

	drop table 
		#databases,
		#excludeObjects,
		#exclude_databases


	
	if exists (select * from sys.server_event_sessions where name = @xsession)
	begin		
		exec ('drop event session [' + @xsession + '] on server')
	end


end 


