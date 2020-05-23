/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jan 2014</Date>
	<Title>Server name</Title>
	<Description>The @@servername property should be configured and set to the same name as the windows server.</Description>
	<Pass>The server name is correctly configured.</Pass>	
	<Fail>The server name is not correctly configured.</Fail>
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

select 
	@@servername as [@@SERVERNAME],
	serverproperty('ServerName') as [SERVERPROPERTY('ServerName')]
where
	convert(varchar(250), @@servername) <> convert(varchar(250), serverproperty('ServerName'))
	or isnull(@@servername, '') = ''
	or isnull(serverproperty('ServerName'), '') = ''
	
