/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Jan 2014</Date>
	<Title>Long running jobs</Title>
	<Description>SQL Agent job should be regularly reviewed to ensure that they do not excessively consume system resources.</Description>
	<Pass>No long running jobs found.</Pass>	
	<Fail>{x} long running jobs found</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


if convert(varchar(250), (select serverproperty('edition'))) not like '%Express%'
begin

	create table #hist(
		Job varchar(250),
		[Seconds] int
	)
	
	insert into #hist (Job, [Seconds])
	select
		j.name as [Job],		
		sum(		
			datediff(second, 			
				convert(datetime, 
					convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4
				), 			   
				dateadd(second, 
					convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 1, 2)) * 60 * 60
					+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 3, 2)) * 60
					+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 5, 2)),
					convert(datetime, convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4)
				) 
			)		
		) as [Seconds]	    
	from 
		msdb..sysjobhistory as h
		
		inner join msdb..sysjobs as j
		on h.job_id = j.job_id
		
	where
		h.step_id = 0 
		and convert(datetime, convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4) >= dateadd(hour, -24, getdate())
		
	group by
		j.name
		
	
	
	
	select
		Job,
		right('00' + convert(varchar(2), ([Seconds] / 60) / 60), 2) 		
		+ ':' + right('00' + convert(varchar(2), ([Seconds] - (([Seconds] / 60) / 60) * 60 * 60) / 60), 2)		
		+ ':' + right('00' + convert(varchar(2), [Seconds] % 60), 2) 
		as [Cumulative duration over last 24 hours (hh:mm:ss)]
	from #hist
	
	where
		[Seconds] / 60 >= 30 --minutes
	
	order by
		[Seconds] desc
	
	
	
	
	drop table #hist
	
end