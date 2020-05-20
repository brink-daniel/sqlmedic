/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>04 Jan 2014</Date>
	<Title>SQL Connectivity</Title>
	<Description>Dummy script used to test SQL connectivity</Description>
	<Pass>Connection to SQL Server instance was successful.</Pass>	
	<Fail>Failed to connect to the specified SQL Server instance.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>minute</Frequency>
	<Category>General</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select getdate() where 1 = 0