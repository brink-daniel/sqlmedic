/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>04 Dec 2013</Date>
	<Title>Global trace flags</Title>
	<Description>Trace flags are used for diagnostic purposed and should be disabled when no longer required.</Description>
	<Pass>No globally enabled trace flags found.</Pass>	
	<Fail>{x} globally enabled trace flags found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

create table #flags (
	TraceFlag int,
	[Status] int,
	[Global] int,
	[Session] int
)

insert into #flags (TraceFlag, [Status], [Global], [Session])
exec ('dbcc tracestatus(-1) with no_infomsgs')

select
	TraceFlag as [Trace flag], 
	[Status], 
	[Global], 
	[Session]
from #flags
order by
	TraceFlag

drop table #flags