
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Jan 2014</Date>
	<Title>Untrusted foreign keys</Title>
	<Description>Keys and constraints may be disabled in order to speed up large data imports, but if re-enabled incorrectly will remain unused, thus resulting in poor query performance.</Description>
	<Pass>No untrusted foreign keys or check constraints found.</Pass>	
	<Fail>{x} untrusted foreign key(s) or check constraint(s) found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

create table #key (
	[Database] varchar(250),
	[Table] varchar(250),
	[Foreign key] varchar(250),
	[Type] varchar(250),
	[Is not trusted] bit
)



exec sp_msforeachdb '

	use [?]

	if ''?'' not in (''master'', ''tempdb'', ''model'', ''msdb'', ''ReportServer'', ''ReportServerTempDB'')
	begin

		insert into #key ([Database],[Table],[Foreign key],[Type],[Is not trusted])
		select 	
			''?'' as [Database],
			object_name([parent_object_id]) as [Table],  
			name as [Foreign key],
			type_desc as [Type],
			is_not_trusted as [Is not trusted] 
	
		from [?].sys.foreign_keys

		where 
			is_not_trusted = 1 
			and is_not_for_replication = 0 
			and is_disabled = 0

		option (recompile)

	end
		  
'

select
	[Database],
	[Table],
	[Foreign key],
	[Type],
	[Is not trusted]
from #key

order by
	[Database],
	[Table],
	[Foreign key]

drop table #key
