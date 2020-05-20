/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Jan 2014</Date>
	<Title>Brute force attacks</Title>
	<Description>This check looks for possible malicious attempts to hack your SQL Server instance, by trying to guess passwords. This is done by reading the current error log and searching for multiple failed login attempts from the same IP address. Please note that this requires that “Login auditing for failed logins” is enabled in the properties of your SQL Server instance and elevated access rights to execute sp_readerrorlog. This script was first published on SQL Server Central by Daniel Brink on 26 July 2013 under the title Passively detect attempts to guess passwords (http://www.sqlservercentral.com/scripts/Security/99423/). This check requires SysAdmin rights.</Description>
	<Pass>No attempts to guess passwords within the last 24 hours were detected.</Pass>	
	<Fail>{x} attempt(s) to guess passwords within the last 24 hours was detected.</Fail>
	<Check>true</Check>
	<Advanced>true</Advanced>
	<Frequency>daily</Frequency>
	<Category>Security</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


if exists (
	select 
		loginname 
	from master.sys.syslogins
	where 
		sysadmin = 1
		and loginname = suser_name()
)
begin

	create table #errorLog (
		LogDate datetime, 
		ProcessInfo varchar(250), 
		[Text] varchar(8000)
	)
	

	--read the current error log 
	insert into #errorLog (LogDate, ProcessInfo, [Text])
	exec sp_readerrorlog 0, 1 --0 = current(0), 1 = error log


	--find brute force attempts to guess a password
	select 
		replace(right([Text],charindex(' ', reverse([Text]))-1), ']', '') as IP,		
		substring([Text], charindex('''', [Text]) + 1,  charindex('.', [Text]) - charindex('''', [Text]) - 2  ) as [User],
		count(LogDate) as [Attempts],
		min(LogDate) as [Started],
		max(LogDate) as [Ended],
		datediff(minute, min(LogDate), max(LogDate)) as [Duration],
		cast(cast(count(LogDate) as decimal(18,2))/isnull(nullif(datediff(minute, min(LogDate), max(LogDate)),0),1) as decimal(18,2)) as [Intensity]
	  
	from #errorLog

	where
		--limit data to unsuccessful login attempts in the last 24 hours
		ProcessInfo = 'Logon'
		and [Text] like 'Login failed for user%'
		and datediff(hour, LogDate, getdate()) <= 24 
	
	group by		
		[Text]
	
	having
		count(LogDate) > 3 --filter out users just typing their passwords incorrectly
	
	order by		
		[Attempts] desc,
		[Ended] desc	



	--clean up temp tables created
	drop table #errorLog


end