/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>16 Nov 2016</Date>
	<Title>Statement sub-tree cost</Title>
	<Description>Extract sub-tree cost of parallel statements from currently execution plan cache. This information is useful when setting the cost threshold for parallelism server configuration option.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


create table #StatementSubTreeCost(
	StatementSubTreeCost decimal(18,2)
);


  
with xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan') 
insert into #StatementSubTreeCost (StatementSubTreeCost) 
select 
    cast(n.value('(@statementsubtreecost)[1]', 'varchar(128)') as decimal(18,2)) as StatementSubTreeCost
from 
	sys.dm_exec_cached_plans as cp 

	cross apply sys.dm_exec_query_plan(cp.plan_handle) as qp 

	cross apply query_plan.nodes('/showplanxml/batchsequence/batch/statements/stmtsimple') as qn(n) 

where n.query('.').exist('//relop[@physicalop="parallelism"]') = 1
  


select 
	count(StatementSubTreeCost) as count,
	avg(StatementSubTreeCost) as avg,
	min(StatementSubTreeCost) as min,
	max(StatementSubTreeCost) as max,
	(
		select top 1 
			StatementSubTreeCost as mode 
		from   #StatementSubTreeCost 
		group by StatementSubTreeCost 
		order by count(StatementSubTreeCost) desc
	) as mode, --most frequent
	(
		select top 1
			percentile_cont(0.5) within group (order by StatementSubTreeCost) over () as median
		from #StatementSubTreeCost
	) as median --value in middle if values sorted by value
	

from #StatementSubTreeCost
  

drop table #StatementSubTreeCost