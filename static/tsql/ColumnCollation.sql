/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jan 2014</Date>
	<Title>Column collation</Title>
	<Description>Tables with a different column collation to the database they are located in can cause collation conflict errors and unexpected query results if not handled correctly.</Description>
	<Pass>All columns have the same collation as the database they are located in.</Pass>	
	<Fail>{x} columns found with a different collation to the database in which they are located.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	db_name() as [Database],
	t.name as [Table],
	c.name as [Column],
	(select d.collation_name from sys.databases as d where database_id = db_id()) as [Database Collation],
	c.collation_name as [Column Collation]
from 
	sys.columns as c
			
	inner join sys.tables as t
	on c.[object_id] = t.[object_id]			
			
where
	c.collation_name is not null
	and c.collation_name collate database_default <> (select d.collation_name collate database_default from sys.databases as d where database_id = db_id())