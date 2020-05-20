
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jun 2018</Date>
	<Title>Find the maximum value over multiple columns</Title>
	<Description>Single query to calculate the maximum value over multiple columns.</Description>
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




create table #data (
	column1 int,
	column2 int,
	column3 int,
	column4 int
)


insert into #data (column1, column2, column3, column4)
values 
	(1, 2, 3, 4), 
	(5, 6, 7, 8),
	(9, 10, 11, 12),
	(13, 14, 15, 16)


--demo data
select * from #data


--find max value over multiple columns
select
	max(x.max_row_value) as [Max value over all columns]
from 
	(
		select       
			(				
				select
					max(d.[value])
				from (values (column1), (column2), (column3), (column4)) as d([value])
			)
		from #data
	) as x (max_row_value)



drop table #data