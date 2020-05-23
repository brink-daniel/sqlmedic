/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>04 Mar 2014</Date>
	<Title>Many non-clustered indexes</Title>
	<Description>SQL Server allows many non-clustered indexes to be created on a single table. While this can speed up query performance, it can also harm the overall performance of all queries touching the table as all the indexes have to be updated each time an insert, update or delete is performed on the table.</Description>
	<Pass>No tables with more than 3 non-clustered indexes found.</Pass>	
	<Fail>{x} tables found with more than 3 non-clustered indexes.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Index</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


create table #indexes (
	database_id int,
	[object_id] int,
	[indexes] int,
	[Table] varchar(250)
)


EXEC sp_msforeachdb '
	use [?]
	
	insert into #indexes (database_id, [object_id], [indexes], [Table])
	select 
		db_id() as database_id, 
		[object_id], 
		count(index_id) as indexes,
		object_name([object_id]) as [Table]
		
	from sys.indexes
	where 
		name is not null
		and type_desc = ''NONCLUSTERED''
		
	group by
		[object_id]
		
	having
		count(index_id) > 3	

	option (recompile)
	
'




select 
	db_name(i.database_id) as [Database],
	[Table],
	i.[indexes] as [Nonclustered indexes]

from #indexes as i

where db_name(i.database_id) not in ('master', 'msdb', 'tempdb', 'model', 'ReportServer', 'ReportServerTempDB')
		
order by
	i.[indexes] desc,
	db_name(i.database_id),
	[Table]
	



drop table #indexes