/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Database read-only mode</Title>
	<Description>Databases can be set into read-only mode for various reasons, such as migrating data, but should be set back into read-write mode afterwards to allow normal system operation.</Description>
	<Pass>All databases are in read-write mode.</Pass>	
	<Fail>{x} database(s) are in a read-only mode.</Fail>
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
	is_read_only as [Is read only]
from sys.databases
where is_read_only = 1
order by name
