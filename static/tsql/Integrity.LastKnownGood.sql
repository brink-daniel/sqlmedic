
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jul 2020</Date>
	<Title>Last known good</Title>
	<Description>When did DBCC CHECKDB last run without reporting any corruptions?</Description>
	<Pass></Pass>
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Integrity</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


drop table if exists #tmp

create table #tmp (
	ParentObject varchar(250)
	,[Object] varchar(250)
	,Field varchar(250)
	,[VALUE] varchar(250)
	,[DB] varchar(250)
)

exec sp_msforeachdb @command1='
	insert into #tmp (ParentObject, [Object], Field, [VALUE])
	exec sys.sp_executesql N''dbcc dbinfo(@db) with tableresults'', N''@db varchar(250)'', @db = ''?''

	update #tmp
	set
		[DB] = ''?''
	where [DB] is null
'

select
	[DB]
	,[VALUE]
from #tmp
where Field = 'dbi_dbccLastKnownGood'
order by [DB]