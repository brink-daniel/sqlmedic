
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Procedures</Title>
	<Description>Stored procedure performance statistics</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_ProcedureStats</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select
	getdate() as [TimeStamp],	
	@@servername as [Server],
	db_name(database_Id) as [Database], 
	object_name([object_id], database_Id) as [Procedure],     
	last_elapsed_time/1000000 as [LastElapsedTime], 
	min_elapsed_time/1000000 as [MinElapsedTime], 
	max_elapsed_time/1000000 as [MaxElapsedTime], 
	execution_count as [ExecutionCount], 
	total_elapsed_time/1000000 as [TotalElapsedTime], 
	(total_elapsed_time/execution_count)/1000000 as [AvgExecutionTime], 
	convert(decimal(18,2), ((total_logical_reads - total_physical_reads * 1.0) / nullif(total_logical_reads, 0.0)) * 100.0) as [BufferHitRatio] 
					 
from sys.dm_exec_procedure_stats
where
	db_name(database_Id) is not null
	and object_name([object_id], database_Id) is not null
	