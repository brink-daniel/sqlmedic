/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>24 Dec 2016</Date>
	<Title>Find table referenced by foreign key</Title>
	<Description>Query the sys.foreign_keys table in order to track down all FK constraints on a specific table. This is useful when resolving the table truncate error "Cannot truncate table '%' because it is being referenced by a FOREIGN KEY constraint".</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Example</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

select
	db_name() as [Database],
	object_name(f.parent_object_id) as [Table],
	f.name as ForeignKey,
	col_name(f.parent_object_id,c.parent_column_id) as [Column],
	object_name (f.referenced_object_id) as ReferencedTable,	
	col_name(f.referenced_object_id, c.referenced_column_id) as ReferencedColumn	
	
from 
	sys.foreign_keys as f

	inner join sys.foreign_key_columns as c
	on f.OBJECT_ID = c.constraint_object_id
	
where object_name(f.referenced_object_id) = 'your table name here'