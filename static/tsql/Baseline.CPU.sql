/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>CPU Usage</Title>
	<Description>Get the current CPU utilization percentage</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>minute</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_CPU</store>
	<Window>00:00 - 23:59</Window>
	<Days>M0WTFSS</Days>
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