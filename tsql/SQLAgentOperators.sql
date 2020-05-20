/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Agent operators</Title>
	<Description>SQL Agent Operators should be configured to allow for system and job alerts to be sent.</Description>
	<Pass>Operators found.</Pass>	
	<Fail>Configuration problems found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>hourly</Frequency>
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
		'There are no SQL Agent Operators configured or they are incorrectly configured and not used.' as Error
	where not exists (
		select 
			* 
		from msdb.dbo.sysoperators
		where
			[enabled] = 1
			and email_address is not null
			and len(email_address) > 0
			and last_email_date is not null	
	)
end

