/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Nov 2013</Date>
	<Title>Server information</Title>
	<Description>Basic information about the SQL Server instance.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

declare
	@startDate datetime 
	
select
	@startDate = (select top 1 coalesce(create_date,getdate()) from sys.databases where name = 'tempdb')

create table #sysinfo (
	[Index] INT,
	Name NVARCHAR(100) collate database_default,
	Internal_Value BIGINT,
	Character_Value NVARCHAR(1000) collate database_default
)

insert into #sysinfo ([Index], Name, Internal_Value, Character_Value)
exec master.dbo.xp_msver


select
	@@servername as [SQL instance],
	'Microsoft SQL Server ' + convert(nvarchar(128), serverproperty('productversion')) + ' ' + convert(nvarchar(128), serverproperty('productlevel')) + ' ' + convert(nvarchar(128), serverproperty('edition')) as [Version],
	getdate() as [Server date & time],
	convert(varchar, datediff(hour, @startDate, getdate()) / 24) + ' days, ' + convert(varchar, datediff(hour, @startDate, getdate()) % 24) + ' hours & ' + convert(varchar, datediff(minute, @startDate, getdate()) % 60) + ' minutes' as Uptime,
	(select top 1
		'Windows ' + COALESCE(a.[Character_Value],'N/A') + ' Version ' + COALESCE(b.[Character_Value],'N/A')
	from 
		#sysinfo as a 
		cross apply #sysinfo as b 
	where 
		a.Name = 'Platform'
		and b.Name = 'WindowsVersion'
	) as [Operating system],
	(select top 1 convert(decimal(26,2), Internal_Value / 1024.0) from #sysinfo where Name= 'PhysicalMemory') as [Memory (GB)],	
	(select count(*) from sys.dm_os_schedulers where is_online = 1 and scheduler_id < 255) as [CPU Cores],
	(select top 1 convert(sysname, serverproperty('collation')) from sys.sysprocesses where spid=1) as [Server Collation]




drop table #sysinfo
