/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2014</Date>
	<Title>Data file location</Title>
	<Description>The server will fail and stop responding if the databases grow and use up all the storage space on which the server operating system is installed.</Description>
	<Pass>No databases are stored on the same drive as the server operating system.</Pass>	
	<Fail>{x} databases are stored on the same drive as the server operating system.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Stability</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	d.name as [Database],
	f.name as [Data file],
	f.physical_name as [Path]
from 
	sys.databases as d
	
	inner join sys.master_files as f
	on d.database_id = f.database_id
		and f.type_desc = 'ROWS'
		and f.physical_name like 'C:\%'

order by
	d.name







	
	


