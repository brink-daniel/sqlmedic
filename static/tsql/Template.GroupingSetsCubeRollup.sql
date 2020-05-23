/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Group by</Title>
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






select
	empid,
	year(shippeddate) as year,
	count(shippeddate) as shipped,
	count(*) as orders,
	grouping(empid),  -- 1 = is grouping
	grouping(year(shippeddate)),  -- 1 = is grouping
	grouping_id(empid, year(shippeddate)) --bitmap
from Sales.Orders
group by
	empid,
	year(shippeddate);






select
	empid,	
	count(*) as orders
from Sales.Orders
group by
	empid 
	with rollup; --add sum totals
	






select
	empid,
	year(shippeddate) as year,
	count(shippeddate) as shipped,
	count(*) as orders,
	grouping(empid),  -- 1 = is grouping
	grouping(year(shippeddate)),  -- 1 = is grouping
	grouping_id(empid, year(shippeddate)) --bitmap
from Sales.Orders
group by grouping sets
(
	(empid), --year column will be null
	(year(shippeddate)), --empid column will be null
	(empid, year(shippeddate)),
	() --empty

)
order by
	1,2,3,4



select
	empid,
	year(shippeddate) as year,
	count(shippeddate) as shipped,
	count(*) as orders,
	grouping(empid), -- 1 = is grouping
	grouping(year(shippeddate)), -- 1 = is grouping
	grouping_id(empid, year(shippeddate)) --bitmap
from Sales.Orders
group by cube --same as grouping sets, all possible permutations
(
	(empid),
	(year(shippeddate))
)
order by
	1,2,3,4



select
	shipcountry,
	shipregion,
	shipcity,
	count(*),
	grouping(shipcountry),-- 1 = is grouping
	grouping(shipregion),  -- 1 = is grouping
	grouping(shipcity), -- 1 = is grouping
	grouping_id(shipcountry,shipregion,shipcity) --bitmap
from Sales.Orders
group by rollup --specify hierarchy
(
	shipcountry,
	shipregion,
	shipcity
)
