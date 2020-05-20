
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Fixed drives</Title>
	<Description>Free space on fixed drives</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_FixedDrive</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted

create table #drives (
	drive char(1),
	[MB free] int
)

insert into #drives (drive, [MB free])
exec master.dbo.xp_fixeddrives


select
	getdate() as [TimeStamp],
	@@servername as [Server],
	drive,
	[MB free] as [MB_free]
from #drives

drop table #drives