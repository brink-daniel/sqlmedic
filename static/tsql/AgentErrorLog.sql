/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Jan 2014</Date>
	<Title>Old agent error log history files</Title>
	<Description>Keeping old agent error log files on the server can use up vital physical storage resources.</Description>
	<Pass>No agent error log files older than 3 months found.</Pass>	
	<Fail>{x} agent error log file(s) older than 3 month were found.</Fail>
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

if convert(varchar(250), (select serverproperty('edition'))) not like '%Express%'
begin

	create table #log (
		[Archive #] int,
		[Date] datetime,
		[Log File Size (Byte)] bigint
	)

	insert into #log ([Archive #], [Date], [Log File Size (Byte)])
	exec master.dbo.xp_enumerrorlogs 2 --1 = server, 2 = agent


	select 
		[Archive #], 
		[Date], 
		[Log File Size (Byte)] 
	from #log
	where
		[Date] < dateadd(month, -3, getdate()) --older than 3 month

	drop table #log


end