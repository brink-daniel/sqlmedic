/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Jan 2014</Date>
	<Title>Database owner</Title>
	<Description>All databases should be owned by the system administrator account. The sid (0x01) of the sa account is always the same across all SQL Server instances, thus setting the database owner to sa makes it easy to move a database to another instance. This also allow user specific logins to be removed when they leave the company.</Description>
	<Pass>All databases are owned by the sa login.</Pass>	
	<Fail>{x} database(s) not owned by the sa login.</Fail>
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
	suser_sname(owner_sid) [Owner]
from sys.databases
where
	suser_sname(owner_sid) <> 'sa'
	and state_desc = 'ONLINE'

order by
	name
	
	
