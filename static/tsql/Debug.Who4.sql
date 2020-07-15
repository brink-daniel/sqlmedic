/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>14 Jul 2020</Date>
	<Title>Current activity</Title>
	<Description>See all user queries that are currently running, including the query plan and job names.</Description>
	<Pass></Pass>
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


select
	r.session_id as spid
	,r.blocking_session_id as blocked_by
	,r.status
	,isnull(cast(object_name(t.objectid, t.dbid) as varchar(1000)), i.event_info) as object_name	
	,db_name(r.database_id) as [db]	
	,convert(decimal(26,2), r.cpu_time / 1000.0) as cpu_time
	,convert(decimal(26,2), r.total_elapsed_time / 1000.0) as total_time
	,(r.reads * 8) / 1000 as reads_mb
	,(r.writes * 8) / 1000 as writes_mb
	,cast((r.logical_reads * 8) / 1000000.0 as decimal(26,2)) as logical_reads_gb
	,r.row_count as [rows]
	,(r.granted_query_memory * 8) /1000 as memory_mb
	,r.open_transaction_count as open_tran
	,isnull(j.name, s.program_name) as program	
	,isnull(nullif(s.login_name, ''), s.original_login_name) as login
	,s.host_name
	,try_cast(p.query_plan as xml) as query_plan
	

from
	sys.dm_exec_requests as r

	inner join sys.dm_exec_sessions as s
	on s.session_id = r.session_id
		and s.is_user_process = 1
	
	cross apply sys.dm_exec_sql_text(r.sql_handle) as t

	cross apply sys.dm_exec_input_buffer(s.session_id, r.request_id) as i

	cross apply sys.dm_exec_text_query_plan(r.plan_handle, r.statement_start_offset, r.statement_end_offset) as p

	left join msdb..sysjobs as j
	on j.job_id = case when s.program_name like 'SQLAgent - TSQL JobStep (Job % : Step %)' then cast(Convert(binary(16), substring(s.program_name, 30, 34), 1) as uniqueidentifier) else null end
				
		
where 
	r.session_id <> @@spid
	and r.cpu_time > 0

order by
	r.total_elapsed_time desc