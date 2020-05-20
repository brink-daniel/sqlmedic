/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Auto close</Title>
	<Description>If a database is configured to automatically close when not in use, it will take long to respond to queries when accessed again.</Description>
	<Pass>No databases are configured to auto close when not in use.</Pass>	
	<Fail>{x} database(s) are configured to auto close when not in use.</Fail>
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
	is_auto_close_on as [Is auto close on]
from sys.databases 
where 
	is_auto_close_on = 1
	and state_desc = 'ONLINE'

order by
	name