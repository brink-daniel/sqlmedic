/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Jan 2014</Date>
	<Title>Disabled indexes</Title>
	<Description>Indexes may be disabled in order to speed up large data manipulations, but by neglecting to re-enable them afterwards will cause queries to perform badly.</Description>
	<Pass>All indexes are enabled.</Pass>	
	<Fail>{x} disabled index(es) found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Index</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select
	db_name() as [Database],
	object_name(i.[object_id]) as [Table],	
	i.name as [Index],
	i.type_desc as [Type],
	i.is_disabled as [Is disabled]

from sys.indexes as i 
		
where i.is_disabled = 1