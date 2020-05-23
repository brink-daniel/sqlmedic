/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>PIVOT and UNPIVOT</Title>
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





--PIVOT
with data as (
	select
		custid, --grouping col
		shipperid, --spreading col, rows to go into columns 
		freight -- aggregate col
	from Sales.Orders
) --use CTE else all other cols become grouping elements
select
	p.custid,
	isnull(p.[1], 0) as ShipperID1,
	isnull(p.[2], 0) as ShipperID2,
	isnull(p.[3], 0) as ShipperID3
into #pivot
from data as d
pivot (
	sum(d.freight) --only 1 aggregate allowed
	for d.shipperid in ([1], [2], [3]) --row values to become columns, static list, use dynamic sql as workaround
) as p

order by p.custid


--notes
-- count(*) not allowed, must specify a column name


select * from #pivot;

--UNPIVOT
with data as (
	select
		custid,
		isnull(ShipperID1, 0) as ShipperID1, 
		isnull(ShipperID2, 0) as ShipperID2,
		isnull(ShipperID3, 0) as ShipperID3
	from #pivot
)
select
	u.custid,
	case u.shipperid 
		when 'ShipperID1' then 1
		when 'ShipperID2' then 2
		when 'ShipperID3' then 3
	end as shipperid,
	u.freight
from data as d
unpivot (
	freight --target col with source value, only 1 aggregate allowed
	for shipperid in (ShipperID1, ShipperID2, ShipperID3) --target col with source column names, static list, use dynamic sql as workaround
) as u

order by 
	u.custid, 
	u.freight


--note
-- unpivot will filter out nulls from results unless you replace the null with 0


drop table #pivot