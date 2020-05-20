/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>13 Jan 2014</Date>
	<Title>User objects</Title>
	<Description>It is not recommended to create any custom tables, stored procedures or other objects in the system databases as these database are often not restored onto new environments and thus vital parts of your system may not be available.</Description>
	<Pass>No custom user objects found in the system databases.</Pass>	
	<Fail>{x} custom user object(s) found in the system databases.</Fail>
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
	'master' as [Database],
	name as [Object],
	type_desc as [Type] 
from master.sys.objects
where 
	is_ms_shipped = 0
		
union all

select
	'msdb' as [Database],
	name as [Object],
	type_desc as [Type] 
from msdb.sys.objects
where 
	is_ms_shipped = 0
	and name <> 'sysdtslog90'

union all

select
	'model' as [Database],
	name as [Object],
	type_desc as [Type] 
from model.sys.objects
where 
	is_ms_shipped = 0
	
order by
	[Database],
	[Object],
	[Type]