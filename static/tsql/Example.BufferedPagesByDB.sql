/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Buffered pages by database</Title>
	<Description>View buffered pages (data) by database</Description>
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
       case [database_id] 
              when 32767 then 
                     'Resource DB'        
              else 
                     db_name([database_id]) 
       end as [Database], 
       count_big(*) as [Pages Buffered],
       (count_big(*) * 8.0) / 1024.0 as [Pages Buffered (MB)],
       cast((((count_big(*) * 8.0) / 1024.0) / (select cast(value as decimal(26,2)) from sys.configurations where name = 'max server memory (MB)')) * 100.0 as decimal(26,2)) as [Pages Buffered (% SQL RAM)], --assumes max memory server property is set
	   cast((((count_big(*) * 8.0) / 1024.0) / (select total_physical_memory_kb / 1024.0 from sys.dm_os_sys_memory)) * 100.0 as decimal(26,2)) as [Pages Buffered (% Server RAM)] 

	   
from sys.dm_os_buffer_descriptors
group by 
       database_id
order by
       [Pages Buffered] desc
