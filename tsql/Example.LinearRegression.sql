/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>05 Jun 2016</Date>
	<Title>Simple linear regression</Title>
	<Description>https://en.wikipedia.org/wiki/Regression_analysis#Linear_regression</Description>
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



--https://en.wikipedia.org/wiki/Regression_analysis#Linear_regression
select 
	 [Database],
	 [Procedure], 
		   
	 --simple linear regression        
	 sum((x - x_mean) * (y - y_mean)) * 1.0
	 / nullif(sum((x - x_mean) * (x - x_mean)), 0)
	 as Trend

from
	 (                    
		   
		   select 
				  [Database],
				  [Procedure],
				  
				  --x axis = days
				  avg(datediff(day,@dteStart,[Date])) over(partition by [Database], [Procedure]) as x_mean,
				  datediff(day,@dteStart,[Date]) as x,

				  --y axis = seconds
				  avg(MaxExecTimeSec) over(partition by [Database], [Procedure]) as y_mean,
				  MaxExecTimeSec as y
		   from #tmp
		   --no group by needed, using all columns
		   
	 ) as Calcs

group by 
	 [Database],
	 [Procedure]
