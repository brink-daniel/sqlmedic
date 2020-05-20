/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Agent alert notification</Title>
	<Description>SQL Agent Alerts should be configured to notify an operator and/or run a job when an alert condition is triggered.</Description>
	<Pass>All SQL Agent Alerts are configured correctly to notify an operator or run a job.</Pass>	
	<Fail>{x} SQL Agent Alerts are not configured to notify an operator or run a job.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
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
		name as [Alert]
	from 
		msdb..sysalerts
	where 
		has_notification = 0
		and job_id = '00000000-0000-0000-0000-000000000000'
		
	order by
		name
	
end
