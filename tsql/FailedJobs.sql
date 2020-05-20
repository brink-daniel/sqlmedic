/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Nov 2013</Date>
	<Title>Failed jobs</Title>
	<Description>Failed jobs should be reviewed and re-run if possible.</Description>
	<Pass>No SQL Agent jobs have failed within the last 24 hours.</Pass>	
	<Fail>{x} SQL Agent job(s) have failed within the last 24 hours.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Error</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


if convert(varchar(250), (select serverproperty('edition'))) not like '%Express%'
begin

	select
		j.name as [Job],
		case h.run_status
			when 0 then 'Failed'
			when 1 then 'Succeeded'
			when 2 then 'Retry'
			when 3 then 'Canceled'
		end as [Result],
		max(convert(datetime, 
			convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4
		)) as [Started],    
		max(dateadd(second, 
			convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 1, 2)) * 60 * 60
			+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 3, 2)) * 60
			+ convert(int, substring(right('000000' + convert(varchar(6), h.run_duration), 6), 5, 2)),
			convert(datetime, convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4)
		)) as Ended	
    
	from 
		msdb..sysjobhistory as h
	
		inner join msdb..sysjobs as j
		on h.job_id = j.job_id
	
	where
		h.step_id = 0 
		and datediff(hour, convert(datetime, 
			convert(datetime, rtrim(run_date)) + (run_time * 9 + run_time % 10000 * 6 + run_time % 100 * 10) / 216e4
		), getdate()) <= 24
		and h.run_status <> 1 --not success
	
	group by
		j.name,
		h.run_status

end