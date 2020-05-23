/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>28 Nov 2013</Date>
	<Title>Long connections</Title>
	<Description>Sleeping connections may point to application design problems where connections to SQL Server are opened and never closed. Uncommitted transactions will be rolled back when these connections eventually do close.</Description>
	<Pass>No sleeping connections found.</Pass>	
	<Fail>There are connections open that have been sleeping for more than 1 hour.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>hourly</Frequency>
	<Category>General</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select
	spid,
	db_name(dbid) as [Database],
	cpu as [CPU time],
	physical_io as [Disk read & writes],
	memusage as [Pages in procedure cache],
	login_time as [Login time],
	last_batch as [Last execution time],
	[status] as [Status],
	hostname as [Host name],
	[program_name] as [Program],
	loginame as [Login]
from master..sysprocesses
where
	spid > 50 --exclude sys process
	and [status] = 'sleeping'
	and datediff(minute, last_batch, getdate()) >= 60
	and spid <> @@spid
	and [program_name] not like '%SQLAgent%'
	and [program_name] not like '%Microsoft SQL Server Management Studio%'
	
order by
	last_batch
 
 
 