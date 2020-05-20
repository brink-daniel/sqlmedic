/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jan 2014</Date>
	<Title>IO Bottlenecks</Title>
	<Description>An average IO read stall of longer than 100 milli-seconds on any file is considered slow, however it is not the duration of the IO stall that effects performance but rather the frequency of the IO stalls.</Description>
	<Pass>No IO read stalls detected.</Pass>	
	<Fail>IO read stalls detected on {x} files.</Fail>
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


declare @cut int



select 
	@cut = isnull(avg(io_stall_read_ms / nullif(num_of_reads, 0)) * 150/100, 20)
from 
	sys.dm_io_virtual_file_stats(null, null) as s

	inner join sys.master_files as f
	on s.database_id = f.database_id
		and s.[file_id] = f.[file_id]
				
where
	(io_stall_read_ms / nullif(num_of_reads, 0)) > (
	
		select	
			avg(io_stall_read_ms / nullif(num_of_reads, 0))	
		from 
			sys.dm_io_virtual_file_stats(null, null) as s

			inner join sys.master_files as f
			on s.database_id = f.database_id
				and s.[file_id] = f.[file_id]
				
	) 


if @cut > 1000
begin
	select @cut = 1000
end

if @cut < 100
begin
	select @cut = 100
end


select 
	db_name(s.database_id) as [Database],
	f.name as [File],	
	f.physical_name as [Location],
	f.type_desc as [File type],
	convert(decimal(26,2), ((s.size_on_disk_bytes / 1024.0) / 1024.0)) as [Size (MB)] ,
	(io_stall_read_ms / nullif(num_of_reads, 0)) as [Average time per read (milliseconds)],
	(io_stall_write_ms / nullif(num_of_writes, 0)) as [Average time per write (milliseconds)]

from 
	sys.dm_io_virtual_file_stats(null, null) as s

	inner join sys.master_files as f
	on s.database_id = f.database_id
		and s.[file_id] = f.[file_id]
				
where
	(io_stall_read_ms / nullif(num_of_reads, 0)) > @cut
	


order by
	(io_stall_read_ms / nullif(num_of_reads, 0)) desc
	
	