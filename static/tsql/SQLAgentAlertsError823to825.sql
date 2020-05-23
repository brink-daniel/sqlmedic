/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Missing SQL Agent alerts (Error 823, 824 & 825)</Title>
	<Description>The 824, 824 & 825 error message indicates that there is a problem with underlying storage system or the hardware or a driver that is in the path of the I/O request. You can encounter this error when there are inconsistencies in the file system or if the database file is damaged.</Description>
	<Pass>Alerts for error messages 824, 824 & 825 are correctly configured.</Pass>	
	<Fail>There are {x} missing alerts for error messages 824, 824 & 825.</Fail>
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
	select 'No alert configured for Error 823' as Error where not exists (select * from msdb..sysalerts where message_id = 823)
	union select 'No alert configured for Error 824' as Error where not exists (select * from msdb..sysalerts where message_id = 824)
	union select 'No alert configured for Error 825' as Error where not exists (select * from msdb..sysalerts where message_id = 825)
end
