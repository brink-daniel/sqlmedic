/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>20 Nov 2013</Date>
	<Title>SQL Agent</Title>
	<Description>This check is not applicable for Express or limited versions of SQL Server.</Description>
	<Pass>The SQL Agent is running.</Pass>	
	<Fail>The SQL Agent is not running.</Fail>
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
		'The SQL Agent process was not found to be running in master..sysprocesses' as Error
	where not exists (select * from master..sysprocesses where program_name like N'SQLAgent%')
end	

