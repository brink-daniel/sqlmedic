/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Nov 2020</Date>
	<Title>Capture Deadlock info in error log</Title>
	<Description>Enable trace flag 1222 to record details about all deadlocks in the error log</Description>
	<Pass>No deadlocks occurred within the last 24 hours.</Pass>	
	<Fail>{x} deadlock(s) occurred within the last 24 hours.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

--enable trace flag 1222 globally
dbcc traceon(1222, -1);

--read error log after deadlock occurred
exec sp_readerrorlog

