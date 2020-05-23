/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>23 Nov 2016</Date>
	<Title>Find execution plans with scan logical operators</Title>
	<Description>Find all cached execution plans that are performing index scans, clustered index scans or table scans.</Description>
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
select top 100
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
	and p.query_plan.exist('//RelOp[@LogicalOp="Index Scan" or @LogicalOp="Clustered Index Scan" or @LogicalOp="Table Scan"]')=1
	--and t.dbid = db_id('COAL')

order by UseCounts desc