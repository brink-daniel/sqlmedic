/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>07 Jan 2014</Date>
	<Title>Slow stored procedures</Title>
	<Description>Stored procedures that ran for longer than 5 minute since it was cached or the last execution took longer than 1 minute or has an average execution time longer than 30 seconds are considered to be very slow. Please note that this query and performance metric does not include any procedures (batches) which contain an ALTER TABLE command and all query stats are lost when the server is rebooted or the query altered.</Description>
	<Pass>No slow performing stored procedures found.</Pass>	
	<Fail>{x} slow performing stored procedures found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Performance</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

select top 20
	db_name(database_id) as [Database],
	object_name([object_id], database_id) as [Procedure],	
	right('00' + convert(varchar(250), (last_elapsed_time/1000000) / 60), 2) + ':' + right('00' + convert(varchar(250), (last_elapsed_time/1000000) % 60), 2) as [Last elapsed time (mm:ss)],
	right('00' + convert(varchar(250), (min_elapsed_time/1000000) / 60), 2) + ':' + right('00' + convert(varchar(250), (min_elapsed_time/1000000) % 60), 2) as [Min elapsed time (mm:ss)],
	right('00' + convert(varchar(250), (max_elapsed_time/1000000) / 60), 2) + ':' + right('00' + convert(varchar(250), (max_elapsed_time/1000000) % 60), 2) as [Max elapsed time (mm:ss)],
	execution_count as [Execution count],
	right('00' + convert(varchar(250), (total_elapsed_time/1000000) / 60), 2) + ':' + right('00' + convert(varchar(250), (total_elapsed_time/1000000) % 60), 2) as [Total elapsed time (mm:ss)],
	right('00' + convert(varchar(250), ((total_elapsed_time/execution_count)/1000000) / 60), 2) + ':' + right('00' + convert(varchar(250), ((total_elapsed_time/execution_count)/1000000) % 60), 2) as [Avg execution time (mm:ss)],
	convert(decimal(26,2), ((total_logical_reads - total_physical_reads * 1.0) / nullif(total_logical_reads, 0)) * 100) as [Buffer hit ratio]
	
						
from sys.dm_exec_procedure_stats
where
	db_name(database_Id) not in ('master', 'msdb', 'tempdb', 'model')
	and last_execution_time >= dateadd(hour, -24, getdate())
	and type_desc = 'SQL_STORED_PROCEDURE'
	and (
		max_elapsed_time > 300000000
		or last_elapsed_time > 60000000
		or (total_elapsed_time/execution_count)/1000000 > 30 
		or ((total_logical_reads - total_physical_reads * 1.0) / nullif(total_logical_reads, 0)) * 100 <= 90 
	)
	and (
		((total_elapsed_time/execution_count)/1000000) / 60 <> 0
		or ((total_elapsed_time/execution_count)/1000000) % 60 <> 0
	) 			
	

order by 
	(total_elapsed_time/execution_count) desc
