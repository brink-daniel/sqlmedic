
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Jan 2014</Date>
	<Title>Hard disk free space</Title>
	<Description>Ensure all hard disk drives have at least 5GB free space at all times. 5GB is an arbitrary value and has no associated performance gain or loss, it is simply used as an indicator that the server may be running out of storage space. This check requires SysAdmin rights.</Description>
	<Pass>All hard disk drives have sufficient free space.</Pass>	
	<Fail>{x} hard disk drive(s) running out of free space.</Fail>
	<Check>true</Check>
	<Advanced>true</Advanced>
	<Frequency>hourly</Frequency>
	<Category>Stability</Category>
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

	create table #drives (
		drive varchar(1),
		[MB free] int
	)

	insert into #drives (drive, [MB free])
	exec master..xp_fixeddrives

	select 
		drive as [Drive],
		[MB free]
	from #drives
	where
		[MB free] <= 5120 --5GB

	drop table #drives

end