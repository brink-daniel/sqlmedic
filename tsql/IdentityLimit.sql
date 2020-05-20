/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Dec 2013</Date>
	<Title>Identity limit</Title>
	<Description>This check identifies all tables which have an identity column in which more than 50% of all possible values are already in use.</Description>
	<Pass>No tables found containing columns that are approaching the identity value limits.</Pass>	
	<Fail>{x} table(s) found containing columns that are approaching the identity value limits.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Stability</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


create table #columns (
	id bigint identity(1,1),
	[Database] varchar(250),
	[Table] varchar(250),
	[Column] varchar(250),
	[Created] datetime,
	[Type] varchar(250),
	[IdentCurrent] bigint
)


exec sp_msforeachdb '

	use [?]

	if ''?'' not in (''master'', ''tempdb'', ''msdb'', ''model'')
	begin

		insert into #columns ([Database],[Table],[Column],[Created],[Type],IdentCurrent)
		select 
			db_name() as [Database],
			t.name as [Table],
			c.name as [Column],
			t.create_date [Created],
			y.name as [Type],
			ident_current(db_name() +  ''..'' + t.name) as IdentCurrent

		from 
			[?].sys.tables as t
	
			inner join [?].sys.columns as c
			on t.object_id = c.object_id
				and c.is_identity = 1
		
			inner join [?].sys.types as y
			on c.user_type_id = y.user_type_id
				and y.name in (''int'', ''bigint'', ''smallint'', ''tinyint'')

		where 
			t.is_ms_shipped = 0	
			and t.name not in (''sysdiagrams'')

		option (recompile)

	end
	
'



select 
	[Database],
	[Table],
	[Column],
	[Created],
	[Type],	
	IdentCurrent,	
	case 
		when [Type] = 'int' then 2147483647.0 
		when [Type] = 'bigint' then 9223372036854775807.0
		when [Type] = 'smallint' then 32767.0
		when [Type] = 'tinyint' then 255.0
	end as IdentMax,
	convert(decimal(26,2), (IdentCurrent/ ( 
		case 
			when [Type] = 'int' then 2147483647.0 
			when [Type] = 'bigint' then 9223372036854775807.0
			when [Type] = 'smallint' then 32767.0
			when [Type] = 'tinyint' then 255.0
		end		
	) ) * 100.0) as [% ID Values Used]

from #columns

where convert(decimal(26,2), (IdentCurrent/ ( 
		case 
			when [Type] = 'int' then 2147483647.0 
			when [Type] = 'bigint' then 9223372036854775807.0
			when [Type] = 'smallint' then 32767.0
			when [Type] = 'tinyint' then 255.0
		end		
	) ) * 100.0) >= 50

order by	
	[% ID Values Used] desc
	


drop table #columns
	
	
	
	
	
