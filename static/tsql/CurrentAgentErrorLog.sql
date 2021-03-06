/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Jan 2014</Date>
	<Title>Current agent error log file</Title>
	<Description>An excessively large or old current agent error log file makes querying error history slow. This problem can easily be fixed by recycling the agent error log using the following script: exec msdb.dbo.sp_cycle_agent_errorlog.</Description>
	<Pass>The current agent error log file is less than 1 month old and smaller than 10 MB.</Pass>	
	<Fail>The current agent error log file is older than 1 month or bigger than 10 MB.</Fail>
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
		[Archive #] = 0 --current
		and (
			[Date] < dateadd(month, -1, getdate()) --older than 1 month
			or [Log File Size (Byte)] > 10000000 --greater than 10 MB
		)

	drop table #log

end