

/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Jobs failure alert</Title>
	<Description>It is recommended to configure all SQL Agent Jobs to send an alert email when the job fails.</Description>
	<Pass>All jobs are configured to notify an operator when they fail.</Pass>	
	<Fail>{x} jobs found which are not set to alert an operator when they fail.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Stability</Category>
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
		name as [Job],
		[description] as [Description]
	from msdb..sysjobs
	where 
		(
			notify_level_email <> 2 --When the job fails
			or notify_email_operator_id = 0
		)
		and [description] <> 'This job is owned by a report server process. Modifying this job could result in database incompatibilities. Use Report Manager or Management Studio to update this job.'
		and [enabled] = 1

end