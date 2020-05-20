/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>25 Feb 2015</Date>
	<Title>Procedure performance statistics</Title>
	<Description>Get aggregate performance statistics for cached stored procedures.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

select
	db_name(database_id) as [Database],
	object_name([object_id], database_id) as [Procedure],	
	cached_time as [Cached],
	last_execution_time as [Last executed],
	execution_count as [Execution count],
	
	total_worker_time /1000 as [CPU time total (sec)],
	last_worker_time / 1000 as [CPU time last (sec)],
	min_worker_time / 1000 as [CPU time min (sec)],
	max_worker_time / 1000 as [CPU time max (sec)],
	
	total_physical_reads as [Disk reads total],
	last_physical_reads as [Disk reads last],
	min_physical_reads as [Disk reads min],
	max_physical_reads as [Disk reads max],
	
	total_logical_writes as [Cache writes total],
	last_logical_writes as [Cache writes last],
	min_logical_writes as [Cache writes min],
	max_logical_writes as [Cache writes max],
	
	total_logical_reads as [Cache reads total],
	last_logical_reads as [Cache reads last],
	min_logical_reads as [Cache reads min],
	max_logical_reads as [Cache reads max],
	
	total_elapsed_time /1000 as [Execution time total (sec)],
	last_elapsed_time /1000 as [Execution time last (sec)],
	min_elapsed_time /1000 as [Execution time min (sec)],
	max_elapsed_time /1000 as [Execution time max (sec)]
	
from sys.dm_exec_procedure_stats
		
where object_name([object_id], database_id) = 'procedureName'
	



