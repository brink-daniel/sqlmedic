/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Jan 2014</Date>
	<Title>Hypothetical indexes</Title>
	<Description>Hypothetical indexes are fake indexes created by the Database Engine Tuning Advisor. There is no performance loss or gain associated with these hypothetical indexes, but they might fool the unsuspecting into thinking an indexes already exist when doing query optimisation.</Description>
	<Pass>No hypothetical indexes found.</Pass>	
	<Fail>{x} hypothetical index(es) found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Index</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



set transaction isolation level read uncommitted


create table #index (
	[Database] varchar(250),
	[Table] varchar(250),
	[Index] varchar(250),
	[Type] varchar(250),
	[Is hypothetical] bit
)


exec sp_msforeachdb ' 
	insert into #index ([Database],[Table],[Index],[Type],[Is hypothetical])
	select
		''?'' as [Database],
		object_name(i.[object_id]) as [Table],	
		i.name as [Index],
		i.type_desc as [Type],
		i.is_hypothetical as [Is hypothetical]
	from
		[?].sys.indexes as i
		
	where
		i.is_hypothetical = 1

	option (recompile)
'


select
	[Database],
	[Table],
	[Index],
	[Type],
	[Is hypothetical]

from #index

order by
	[Database],
	[Table],
	[Index]


drop table #index

