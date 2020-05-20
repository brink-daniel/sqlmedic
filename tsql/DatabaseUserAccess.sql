
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Database user access mode</Title>
	<Description>By default all databases should be in MULTI_USER mode to allow concurrent connections.</Description>
	<Pass>All databases are in MULTI_USER mode.</Pass>	
	<Fail>{x} database(s) are in a restricted access mode.</Fail>
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
	name as [Databases], 
	user_access_desc as [User access]
from sys.databases
where user_access_desc <> 'MULTI_USER'
order by name


