
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>25 Feb 2015</Date>
	<Title>Job history</Title>
	<Description>Get the execution history of scheduled jobs.</Description>
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



declare 
	@InPastXHours int = 24,
	@MinDuration int = 0 --seconds


select
	j.name as [Job],
	case h.run_status
		when 0 then 'Failed'
		when 1 then 'Succeeded'
		when 2 then 'Retry'
		when 3 then 'Canceled'
	end as [Status],
	convert(datetime, 
		convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4
	) as [Started],    
    dateadd(second, 
		convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 1, 2)) * 60 * 60
		+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 3, 2)) * 60
		+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 5, 2)),
		convert(datetime, convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4)
	) as Ended,
	case h.run_status
		when 1 then ''
		else
			h.[message]
	end as [Message]
    
from 
	msdb..sysjobhistory as h
	
	inner join msdb..sysjobs as j
	on h.job_id = j.job_id
	
where
	h.step_id = 0 
	and (
		(
			convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 1, 2)) * 60 * 60
			+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 3, 2)) * 60
			+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 5, 2))
		) >  @MinDuration
		or h.run_status <> 1
	)
    and datediff(hour, 
		convert(datetime, 
			convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4
		), 
		getdate()
	) <= @InPastXHours
