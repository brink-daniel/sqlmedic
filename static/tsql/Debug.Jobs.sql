/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Apr 2018</Date>
	<Title>Find all jobs that were running at a specific point in time</Title>
	<Description>Query SQL Agent job history to find all jobs that were running at a specific point in time. This script can also easily be adjusted to find all jobs that ran over a specific period of time.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted

declare @time datetime  = '14 Mar 2018 14:00'

select
	*     

from
	(
		select
			j.name as [Job],
			h.step_name as [Step],    
			msdb.dbo.agent_datetime(run_date, run_time) as [Started],    
			dateadd(second,
			convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 1, 2)) * 60 * 60
			+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 3, 2)) * 60
			+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 5, 2)),
			msdb.dbo.agent_datetime(run_date, run_time)
			) as [Ended]
			
		from
			msdb.dbo.sysjobs as j

			inner join msdb.dbo.sysjobhistory as h
			on j.job_id = h.job_id
				and h.step_id <> 0

	) as x
		
where
	x.[Started] <= @time
	and x.[Ended] >= @time

order by
	[Job],
	[Started]