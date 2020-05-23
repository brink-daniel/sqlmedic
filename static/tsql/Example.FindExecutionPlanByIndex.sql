/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>22 Nov 2016</Date>
	<Title>Find execution plan by index</Title>
	<Description>Find all cached execution plans using a specific index.</Description>
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

set transaction isolation level read uncommitted

;with xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
select
	UseCounts, 	
	TEXT, 
	query_plan,
	plan_handle

from
	sys.dm_exec_cached_plans as cp
	
	cross apply sys.dm_exec_sql_text(cp.plan_handle) as t
	
	cross apply sys.dm_exec_query_plan(cp.plan_handle) as p

where 
	cp.Objtype = 'Proc'
	and p.query_plan.exist('//*[@Index=''[your index name here]'']') = 1
	and t.dbid = db_id('COAL')