
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Missing SQL Agent alerts (Severity levels 16 through 25)</Title>
	<Description>SQL Agent Alerts should be configured for Severity levels 16 through 25 as these indicate very serious problems which require immediate attention.</Description>
	<Pass>Alerts for severity levels 16 through 25 are correctly configured.</Pass>	
	<Fail>There are {x} missing alerts for severity levels 16 through 25.</Fail>
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

	select 'No alert configured for Severity 16 - Miscellaneous User Error' as Error where not exists (select * from msdb..sysalerts where severity = 16)
	union select 'No alert configured for Severity 17 - Insufficient resources' as Error where not exists (select * from msdb..sysalerts where severity = 17)
	union select 'No alert configured for Severity 18 - Nonfatal Internal Error' as Error where not exists (select * from msdb..sysalerts where severity = 18)
	union select 'No alert configured for Severity 19 - Fatal Error in Resource' as Error where not exists (select * from msdb..sysalerts where severity = 19)
	union select 'No alert configured for Severity 20 - Fatal Error in Current Process' as Error where not exists (select * from msdb..sysalerts where severity = 20)
	union select 'No alert configured for Severity 21 - Fatal Error in Database Process' as Error where not exists (select * from msdb..sysalerts where severity = 21)
	union select 'No alert configured for Severity 22 - Fatal Error: Table Integrity Suspect' as Error where not exists (select * from msdb..sysalerts where severity = 22)
	union select 'No alert configured for Severity 23 - Fatal Error: Database Integrity Suspect' as Error where not exists (select * from msdb..sysalerts where severity = 23)
	union select 'No alert configured for Severity 24 - Fatal Error: Hardware Error' as Error where not exists (select * from msdb..sysalerts where severity = 24)
	union select 'No alert configured for Severity 25 - Fatal Error' as Error where not exists (select * from msdb..sysalerts where severity = 25)

end