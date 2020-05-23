
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Sep 2015</Date>
	<Title>Auto-growth events</Title>
	<Description>SQL Server requires free space in data in log files to complete data modification commands. Auto file growth events can take a long time to complete based on the size of the file change. It is recommended to manually size files correctly and avoid auto-growth events during process execution.</Description>
	<Pass>No auto-growth events detected in the last 24 hours.</Pass>	
	<Fail>{x} auto-growth events occurred in the last 24 hours.</Fail>
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
   DatabaseName as [Database],
   [FileName] as [File],
    case EventClass 
       when 92 then 'Data'
       when 93 then 'Log'
   end as [Type],
   convert(decimal(26,3), (IntegerData * 8)/1024.0) as [Growth (MB)], 
   Duration/1000 as [Duration (MS)],
   StartTime as [Start],
   EndTime as [End] 
   
from sys.fn_trace_gettable((select reverse(substring(reverse([path]), charindex('\', reverse([path])), 260)) + N'log.trc' from sys.traces where is_default = 1), default)
where
   EventClass in (92,93)
   and StartTime > dateadd(day, -1, getdate())
   
order by
   StartTime desc