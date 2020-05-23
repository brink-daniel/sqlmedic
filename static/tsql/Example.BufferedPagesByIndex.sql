/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Buffered pages by index</Title>
	<Description>View the buffered pages (data) by index for the current database.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
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
	o.name as [Table],                
	i.name as [Index],  
	i.type_desc as [Type],
	count_big(b.page_id) as Pages,
	(count_big(b.page_id) * 8) / 1024 as [Pages (MB)]
       
from 
	sys.dm_os_buffer_descriptors as b

	inner join sys.allocation_units as au
	on b.allocation_unit_id = au.allocation_unit_id
		and au.[type] in (1,2,3)

	inner join sys.partitions as p
	on au.container_id = p.hobt_id

	inner join sys.objects as o
	on p.[object_id] = o.[object_id]
	and o.is_ms_shipped = 0
		--and o.name = 'your table name here' --Change table name here, please do not run this for all tables. A hand full is fine.

	inner join sys.indexes as i
	on o.[object_id] = i.[object_id]
		and p.index_id = i.index_id
              
where 
	b.database_id = db_id() 

group by
	o.name,              
	i.name,
	i.type_desc

order by
	Pages desc
