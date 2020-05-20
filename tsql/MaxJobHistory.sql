/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Job history excessive</Title>
	<Description>Keeping large amounts of job history in the msdb could use up all storage resources and also makes querying and monitoring jobs inefficient.</Description>
	<Pass>No more than 3 months worth of history was found for any jobs.</Pass>	
	<Fail>Excessive job history was found on {x} job(s).</Fail>
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
		min( convert(datetime, rtrim(run_date))) as [Oldest Log Entry],
		datediff(day,isnull(min( convert(datetime, rtrim(run_date))), getdate()), getdate()) as [Days worth of job history]
	from	
		msdb..sysjobs as j
		
		left join msdb..sysjobhistory as h
		on h.job_id = j.job_id

	where
		j.enabled = 1
		and j.description not like 'This job is owned by a report server process.%'
	
	group by
		j.name		
	
	having 
		datediff(month,isnull(min( convert(datetime, rtrim(run_date))), getdate()), getdate()) > 3

	order by
		[Days worth of job history] desc

end