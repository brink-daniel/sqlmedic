/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Recursive CTE</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Template</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/





declare @i int = 9;

with emp as (
	select
		empid,
		mgrid,
		firstname,
		lastname,
		0 as distance
	from HR.Employees
	where empid = @i

	union all

	select
		y.empid,
		y.mgrid,
		y.firstname,
		y.lastname,
		e.distance + 1 as distance
		
	from emp as e

	inner join HR.Employees as y
	on e.mgrid = y.empid
		
)
select 
	* 
from emp



