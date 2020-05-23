/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2014</Date>
	<Title>User database data and log file location</Title>
	<Description>Keeping the database data (*.mdf) and log (*.ldf) files on separate disks drive will help ensure best possible query performance.</Description>
	<Pass>No user database data and log files found on the same drive.</Pass>	
	<Fail>User database data and log files found that are on the same drive.</Fail>
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
	[rows].physical_name as [Data file],
	[log].physical_name as [Log file]
from 
	sys.databases as d
	
	left join (
		select 
			d.name,
			f.physical_name
		from 
			sys.databases as d
			
			inner join sys.master_files as f
			on d.database_id = f.database_id
				and f.type_desc = 'ROWS'	
	) as [rows]
	on d.name = [rows].name
	
	left join (
		select 
			d.name,
			f.physical_name
		from 
			sys.databases as d
			
			inner join sys.master_files as f
			on d.database_id = f.database_id
				and f.type_desc = 'LOG'				

	) as [log]
	on d.name = [log].name

where
	substring([rows].physical_name, 1, 2) = substring([log].physical_name, 1, 2) 
	and d.name not in ('master', 'msdb', 'model', 'tempdb')

order by
	d.name