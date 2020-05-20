/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>23 Sep 2018</Date>
	<Title>Performance of last 100 job steps</Title>
	<Description>This script returns the last 100 job steps executed, showing the duration of each of the job steps in seconds.</Description>
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

select top 100
	j.name as [Job],
	h.step_id as [Step #],
	h.step_name as [Step Name],
	msdb.dbo.agent_datetime(run_date, run_time) as [Started],   
	convert(int, 
		substring(right('000000' + convert(varchar(6), h.run_duration), 6), 1, 2)) * 60 * 60
		+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 3, 2)) * 60
		+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 5, 2)
	) as [Duration (seconds)],
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

order by h.instance_id desc