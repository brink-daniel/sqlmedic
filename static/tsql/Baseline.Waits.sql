/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Waits</Title>
	<Description>Information about all the waits encountered by threads that executed</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_WaitStats</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	getdate() as [TimeStamp],
	@@servername as [Server],		
	*			
from sys.dm_os_wait_stats
where	
	waiting_tasks_count != 0
	or wait_time_ms != 0
	or max_wait_time_ms != 0
	or signal_wait_time_ms != 0