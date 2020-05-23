/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Auto shrink</Title>
	<Description>Automatically shrinking databases in order the create more physical disk space on a server causes index fragmentation which slows down query performance.</Description>
	<Pass>No databases are configured to auto shrink.</Pass>	
	<Fail>{x} database(s) are configured to auto shrink.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	name as [Database], 
	is_auto_shrink_on as [Is auto shrink on] 
from sys.databases
where 
	is_auto_shrink_on = 1
	and state_desc = 'ONLINE'

order by
	name