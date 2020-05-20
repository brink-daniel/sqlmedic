/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2014</Date>
	<Title>High CPU usage</Title>
	<Description>High CPU utilization by SQL Server can be an indicator of performance issues caused by poor query design.</Description>
	<Pass>The CPU utilization is normal.</Pass>	
	<Fail>High CPU utilization detected.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>minute</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select
	dateadd(millisecond, -1 * ((
		select 
			cpu_ticks/(cpu_ticks/ms_ticks) 
		from sys.dm_os_sys_info
	) - [timestamp]), getdate()) as [Time],
	SystemIdle as [Idle],
	ProcessUtilization as [SQL],
	100 - SystemIdle - ProcessUtilization as Other

from (

	select 	
		[timestamp],		
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as SystemIdle,
		record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as ProcessUtilization		
	
	from 
		(
			select			
				[timestamp],
				convert(xml, record) AS [record]			 
			from sys.dm_os_ring_buffers
			where 
				ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
				and record like '%<SystemHealth>%'		
		) as x

) as y

order by [Time] desc


