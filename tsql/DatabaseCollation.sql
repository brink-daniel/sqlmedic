/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Databases collation</Title>
	<Description>Having a different collation on a database to the server's default database collation can result in collation conflict errors and also slow query performance as collation translations has to be done. Also different collations can result in unexpected query results as the data comparison rules may differ.</Description>
	<Pass>All databases are configured with the server collation.</Pass>	
	<Fail>{x} database(s) have a different collation to the tempdb (server collation).</Fail>
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
	name as [Database],
	collation_name as [Collation]
from sys.databases
where
	collation_name <> (select top 1 convert(sysname, serverproperty('collation')) from sys.sysprocesses where spid=1)
	and state_desc = 'ONLINE'
	and name not in ('ReportServer', 'ReportServerTempDB')
