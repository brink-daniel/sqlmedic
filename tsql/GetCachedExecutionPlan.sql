/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>16 Feb 2015</Date>
	<Title>Cached execution plan</Title>
	<Description>Find the cached execution plan for a stored procedure.</Description>
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

declare @procedureName varchar(250) = 'myProcedureName'

select top 10 
	UseCounts, 	
	TEXT, 
	query_plan,
	plan_handle


from 
	sys.dm_exec_cached_plans 
	
	cross apply sys.dm_exec_sql_text(plan_handle)
	
	cross apply sys.dm_exec_query_plan(plan_handle)

where 
	Objtype = 'Proc'
	and [TEXT] like '%' + @procedureName + '%'


--If the cached plan is null, it just means that not all code paths are cached yet. Use the query below to get the parts that are cached.
select 
       cast(query_plan as xml)
from 
       sys.dm_exec_query_stats as qs

       cross apply sys.dm_exec_text_query_plan(qs.plan_handle, qs.statement_start_offset, qs.statement_end_offset) as tp

where 
       qs.plan_handle = XXX --change this


