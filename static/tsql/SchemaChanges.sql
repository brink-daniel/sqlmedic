/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>04 Feb 2014</Date>
	<Title>Schema changes</Title>
	<Description>You should always keep track of all schema changes as these are very useful in debugging issues.</Description>
	<Pass>No schema changes were made in the last 24 hours.</Pass>	
	<Fail>{x} schema changes were made in the last 24 hours.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Stability</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

create table #changes (
	[Database] varchar(250),
	[Object] varchar(250),
	[Type] varchar(250),
	[Created] datetime,
	[Modified] datetime
)


exec sp_msforeachdb '

if ''?'' not in (''tempdb'')
begin

	insert into #changes ([Database],[Object],[Type],[Created],[Modified])
	select 
		''?'' as [Database],
		name as [Object], 
		type_desc as [Type],
		create_date as [Created],
		modify_date as [Modified]
		
	from [?].sys.objects
	where
		is_ms_shipped = 0
		and (
			create_date > dateadd(day, -1, getdate())
			or modify_date > dateadd(day, -1, getdate())
		)
		
	order by
		name

	option (recompile)
		
end
	
'

select * from #changes
order by
	[Database],
	[Object]
	
drop table #changes