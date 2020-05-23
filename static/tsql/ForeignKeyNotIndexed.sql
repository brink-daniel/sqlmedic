/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>22 Apr 2015</Date>
	<Title>Foreign keys not indexed</Title>
	<Description>It is recommended that all foreign key constraints are indexed to improve table joins that involve the primary and foreign keys.</Description>
	<Pass>All foreign keys are indexed.</Pass>	
	<Fail>{x} foreign keys were found that have not been indexed.</Fail>
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
	t.name as [Table],
	fk.name as [Foreign Key],
	c.name as [Column]			
	
from 
	sys.foreign_keys as fk
	
	inner join sys.tables as t
	on fk.parent_object_id = t.[object_id]
	
	inner join sys.foreign_key_columns as fkc
	on fk.[object_id] = fkc.constraint_object_id
	
	inner join sys.columns as c 
	on fkc.parent_object_id	= c.[object_id]
		and fkc.parent_column_id = c.[column_id]
		
	left join sys.index_columns as ic
	on c.[object_id] = ic.[object_id]
		and c.[column_id] = ic.[column_id]
		and ic.is_included_column = 0				

where 
	ic.index_id is null
	and db_name() not in ('tempdb', 'master', 'msdb', 'model', 'ReportServer', 'ReportServerTempDB')

group by
	t.name,
	c.name




