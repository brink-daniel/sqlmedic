
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Jan 2014</Date>
	<Title>Oversized log files</Title>
	<Description>Depending on the specific configurations set, database transaction log files will generally grow as needed. This can result in very large empty files after the transaction log is backed up. If the transaction log grew because of a once-off event consider reducing its size in order free up storage resources on the server for other processes.</Description>
	<Pass>All user database log files are sized correctly.</Pass>	
	<Fail>{x} potentially oversized user database log file(s) found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Maintenance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


create table #perf(
	[Database Name] varchar(250),
	[Log Size (MB)] decimal(26,2),
	[Log Space Used (%)] decimal(26,2),
	[Status] int
)

insert into #perf ([Database Name], [Log Size (MB)], [Log Space Used (%)], [Status])
exec ('dbcc sqlperf(logspace)')

select 
	[Database Name], 
	[Log Size (MB)], 
	convert(varchar(250), convert(decimal(26,2), [Log Size (MB)] * (100.0 - [Log Space Used (%)])/100.0)) + ' (' +  convert(varchar(250),convert(decimal(26,0),(100.0 - [Log Space Used (%)])))  + '%)' as [Free Space (MB)]
	
from #perf
where
	[Log Space Used (%)] < 10
	and [Log Size (MB)] > 1024
	and [Database Name] not in ('master', 'model', 'tempdb', 'msdb')
	
order by
	[Log Size (MB)] desc

drop table #perf
