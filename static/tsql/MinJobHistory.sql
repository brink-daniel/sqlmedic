/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Job history insufficient</Title>
	<Description>It is recommended to keep at least 7 days worth of execution history on all jobs to aid in performance analysis and debugging problems incurred.</Description>
	<Pass>At least 7 days worth of history found for all jobs.</Pass>	
	<Fail>Insufficient history available on {x} jobs.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Maintenance</Category>
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
		j.enabled as [Enabled],
		min( convert(datetime, rtrim(run_date))) as [Oldest Log Entry],
		datediff(day,isnull(min( convert(datetime, rtrim(run_date))), getdate()), getdate()) as [Days worth of job history available]
	from	
		msdb..sysjobs as j
		
		left join msdb..sysjobhistory as h
		on h.job_id = j.job_id
		
	where
		j.enabled = 1
		and j.description not like 'This job is owned by a report server process.%'
	
	group by
		j.name,
		j.enabled		
	
	having 
		datediff(day,isnull(min( convert(datetime, rtrim(run_date))), getdate()), getdate()) < 7

	order by
		[Days worth of job history available] desc
end