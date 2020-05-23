/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Jan 2014</Date>
	<Title>Old server error log history files</Title>
	<Description>Keeping old server error log files on the server can use up vital physical storage resources. Old error log files should be backed up and removed from the server.</Description>
	<Pass>No server error log files older than 3 month found.</Pass>	
	<Fail>{x} server error log files older than 3 month were found.</Fail>
	<Check>true</Check>
	<Advanced>true</Advanced>
	<Frequency>daily</Frequency>
	<Category>Maintenance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

create table #log (
	[Archive #] int,
	[Date] datetime,
	[Log File Size (Byte)] bigint
)

insert into #log ([Archive #], [Date], [Log File Size (Byte)])
exec master.dbo.xp_enumerrorlogs 1 --1 = server, 2 = agent


select 
	[Archive #], 
	[Date], 
	[Log File Size (Byte)] 
from #log
where
	[Date] < dateadd(month, -3, getdate()) --older than 3 month
	

drop table #log