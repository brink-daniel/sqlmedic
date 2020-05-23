/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Window Functions</Title>
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




--notes
-- window functions only allowed in SELECT and ORDER BY
-- default frame is RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

-- RANGE -- includes ties/duplicates with same order
--- unbounded preceding
--- unbounded following
--- current row

-- ROWS -- does not include duplicate, same order, add tiebreaker order by columns, e.g. PK id
--- unbounded preceding
--- unbounded following
--- <n> rows preceding
--- <n> rows following
--- current row





--aggregate

select
	custid,
	orderid,
	orderdate,
	val,

	sum(val) over (partition by custid order by orderdate, orderid rows between unbounded preceding and current row) as runningtotal, 

	sum(val) over (partition by custid) as custtotal, --total by custid
	sum(val) over () as grandtotal --grand total

from Sales.OrderValues 

--ranking

select
	custid,
	orderid,
	val,
	row_number() over (order by val) as rownum, -- row num incremented by each row
	rank()  over (order by val) as rnk, --row num incremented by each unique order by value, next row number skipped on duplicates, e.g. 4, 5, 6, 6, 8
	dense_rank() over (order by val) as densernk, --row num incremented by each unique order by value, next row number NOT skipped on duplicates, e.g. 4, 5, 6, 6, 7
	ntile(100) over (order by val) as ntile100 --partition rows. total rows / 100 = x rows per partition. 

from Sales.OrderValues 


--offset


select
	custid,
	orderid,
	orderdate,
	val,
	-- func(col, offset, default val if null) over (partition by X order by Y)
	lag(val, 1, 0) over (partition by custid order by orderdate, orderid) as prev_val,
	lead(val, 1, 0) over (partition by custid order by orderdate, orderid) as next_val,


	first_value(val) over (partition by custid order by orderdate, orderid) as first_val,
	last_value(val) over (partition by custid order by orderdate, orderid rows between current row and unbounded following) as last_val --must use UNBOUNDED FOLLOWING

from Sales.OrderValues

order by
	custid,
	orderdate, 
	orderid
