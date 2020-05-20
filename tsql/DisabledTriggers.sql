
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Feb 2014</Date>
	<Title>Disabled triggers</Title>
	<Description>Triggers are very useful for auditing data changes, but can be disabled for various reasons.</Description>
	<Pass>No disabled triggers found.</Pass>	
	<Fail>{x} disabled triggers found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Stability</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


select 
	db_name() as [Database],
	object_name(object_id) as [Table], 
	name as [Trigger]	

from sys.triggers
where is_disabled = 1