/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>16 Jan 2014</Date>
	<Title>Offline databases</Title>
	<Description>Databases may be taken offline for various reason, but should be brought back online soon after to ensure applications, and processes such as backups remain functional.</Description>
	<Pass>All databases are online.</Pass>	
	<Fail>{x} databases found which are not currently online.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>General</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

select 
	name as [Database],
	state_desc as [Status]

from sys.databases
where
	state_desc <> 'ONLINE'
	
order by
	name