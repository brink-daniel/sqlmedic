/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Jan 2014</Date>
	<Title>Deadlocks</Title>
	<Description>A deadlock occurs when two or more tasks permanently block each other by each task having a lock on a resource which the other tasks are trying to lock.</Description>
	<Pass>No deadlocks occurred within the last 24 hours.</Pass>	
	<Fail>{x} deadlock(s) occurred within the last 24 hours.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Error</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted

if exists (select * from sys.sysobjects where name = 'dm_xe_session_targets')
begin

	begin try

		select 
			cast(xEventData.xEvent.value('@timestamp', 'datetime') as datetime) as [Timestamp],
			cast(XEventData.XEvent.value('(data/value)[1]', 'varchar(max)') as xml) as [Deadlock graph]
			
		from
			(
				select 
					cast(target_data as xml) as target_data
				from 
					sys.dm_xe_session_targets as st
				
					inner join sys.dm_xe_sessions as s
					on s.[address] = st.event_session_address
			
				where name = 'system_health'
			) as Data

			cross apply target_data.nodes ('RingBufferTarget/event[@name="xml_deadlock_report"]') as XEventData (XEvent) 
		
		where cast(xEventData.xEvent.value('@timestamp', 'datetime') as datetime) >= dateadd(hour, -24, getdate())
		
		order by
			[Timestamp] desc
			
		
	end try
	begin catch
	
	
		--do nothing
			
	
	end catch	
	
	
end