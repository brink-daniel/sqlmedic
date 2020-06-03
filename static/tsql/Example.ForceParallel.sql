/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Jun 2016</Date>
	<Title>Force parallel execution plan</Title>
	<Description>The generation of parallel execution plans can be forced using the undocumented trace flag 8649. Do not use this on production environments.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Example</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select
	*
from VeryLargeTable
where 
	Col1 = 'hello'
	and Col2 > 'World'

option (recompile, querytraceon 8649) -- force parallel execution plan    

--as of SQL 2016 SP1
--option (use hint('ENABLE_PARALLEL_PLAN_PREFERENCE'))
