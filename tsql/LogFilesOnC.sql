/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2014</Date>
	<Title>Log file location</Title>
	<Description>Database log files can possibly grow until the server runs out of hard drive space and fails. Keeping the log files on a separate drive to the operating system will at least ensure that the server stays up and allow the problem to be resolved easier.</Description>
	<Pass>No database log files are on the same drive as the operating system.</Pass>	
	<Fail>{x} database log files are on the same drive as the operating system.</Fail>
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
	f.name as [Log file],
	f.physical_name as [Path]
from 
	sys.databases as d
	
	inner join sys.master_files as f
	on d.database_id = f.database_id
		and f.type_desc = 'LOG'
		and f.physical_name like 'C:\%'

order by
	d.name