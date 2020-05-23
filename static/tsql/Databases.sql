/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>18 Nov 2013</Date>
	<Title>List databases</Title>
	<Description>This script lists all databases on a SQL Server instance including basic database information such as size and collation.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


select 
	d.name as [Database],
	suser_sname(d.owner_sid) AS [Owner],
	d.[compatibility_level] as [Comp. level],
	d.user_access_desc as [User access],
	d.state_desc as [State],
	d.recovery_model_desc as [Recovery model],
	d.collation_name as [Collation],
	sum(((f.size * 8.0)/1024.0) / 1024.0) as [Size (GB)]
	

from 
	sys.databases as d

	inner join sys.master_files as f
	on d.database_id = f.database_id

group by
	d.name,
	d.owner_sid,
	d.[compatibility_level],
	d.user_access_desc,
	d.state_desc,
	d.recovery_model_desc,
	d.collation_name

order by
	[Size (GB)] desc,
	d.name



