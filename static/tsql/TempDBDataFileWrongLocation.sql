/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2014</Date>
	<Title>TempDB location</Title>
	<Description>The tempdb data files should be thought of as log files. Keeping them on a separate drive to the user database data files will ensure better query performance.</Description>
	<Pass>The tempdb data files are on a different drive to the user databases.</Pass>	
	<Fail>The tempdb data files are on the same disk as the user databases.</Fail>
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
	d.name as [Database],
	f.name as [Logical name],
	f.physical_name as [Physical name]
	
from 
	sys.databases as d
	
	inner join sys.master_files as f
	on d.database_id = f.database_id
		and f.type_desc = 'ROWS'
	
where
	d.name = 'tempdb'
	and exists (
		select top 1
			m.physical_name
		from 
			sys.databases as a
			
			inner join sys.master_files as m
			on a.database_id = m.database_id
				and m.type_desc = 'ROWS'				
				
		where
			a.name <> 'tempdb'
			and substring(m.physical_name, 1, 2) = substring(f.physical_name, 1, 2) 	
	)
