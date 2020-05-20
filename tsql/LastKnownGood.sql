/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>04 Dec 2013</Date>
	<Title>Database consistency</Title>
	<Description>DBCC CHECKDB() should be run at least once per week on all databases to ensure logical and physical integrity. This check requires SysAdmin rights.</Description>
	<Pass>All databases have recently passed the integrity checks.</Pass>	
	<Fail>{x} database(s) have not passed the DBCC CHECKDB() integrity check within the last 7 days.</Fail>
	<Check>true</Check>
	<Advanced>true</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Integrity</Category>
	<Foreachdb>true</Foreachdb>
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
and db_name() not in ('tempdb', 'master', 'msdb', 'model', 'ReportServer', 'ReportServerTempDB')
begin


	create table #dbinfo (
		ParentObject varchar(250),
		[Object] varchar(250),
		[Field] varchar(250),
		[VALUE] varchar(250)
	)


	insert into #dbinfo (ParentObject, [Object], [Field], [VALUE])
	exec ('DBCC DBINFO WITH TABLERESULTS')

	
	select top 1
		db_name() as [Database],
		nullif(convert(datetime, [VALUE]), '1900-01-01 00:00:00.000') as [Last known good]
	
	from #dbinfo 
	where 
		[Field] = 'dbi_dbccLastKnownGood'
		and datediff(day, convert(datetime, [VALUE]), getdate()) > 7

		
	drop table #dbinfo
	


end
else
begin
	select
		'' as [Database],
		getdate() as [Last known good]
	where 1 = 0
	

end