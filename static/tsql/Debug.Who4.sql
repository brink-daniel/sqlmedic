/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>14 Jul 2020</Date>
	<Title>Current activity (who4)</Title>
	<Description>See all user queries currently running, including query plan and job names.</Description>
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
	,isnull(object_name(t.objectid, t.dbid), i.event_info) as object_name
	,db_name(r.database_id) as [db]
	,convert(decimal(26,2), r.total_elapsed_time / 1000.0) as total_elapsed_time
	,r.reads
	,r.writes
	,r.logical_reads
	,r.row_count
	,r.granted_query_memory
	,r.open_transaction_count	
	,isnull(j.name, s.program_name) as program_name
	,s.login_name
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
				
		
where r.session_id <> @@spid

order by
	r.total_elapsed_time desc
