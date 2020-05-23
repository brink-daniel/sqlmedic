/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>22 Apr 2015</Date>
	<Title>Non-clustered index keys matching the clustered index</Title>
	<Description>SQL will always choose the narrower index when executing queries and ignore data already cached in memory. Having a non-clustered index with the same keys as the clustered index can thus negatively effect performance as SQL will clear the cache and read the pages from the non-clustered index into memory to execute the query. Removing the non-clustered index, thus leaving the clustered index cached, could be better for more queries as the clustered index contains all columns. Note, this does reduce the amount of data which can be cached if the server has insufficiency RAM installed.</Description>
	<Pass>No non-clustered indexes were found with the same key columns as the clustered index on the table.</Pass>	
	<Fail>{x} non-clustered indexes were found with the same key columns as the clustered index on the table.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Index</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted



select 
	t.name as [Table], 
	i.name as [Index], 
	c.name as [Column],
	ic.key_ordinal as [Key]

into #clust 

from 
	sys.indexes as i 

	inner join sys.tables as t 
	on i.object_id = t.object_id 
		and t.is_ms_shipped = 0 

	inner join sys.index_columns as ic 
	on i.object_id = ic.object_id 
		and i.index_id = ic.index_id 
		and ic.is_included_column = 0

	inner join sys.columns as c 
	on ic.object_id = c.object_id 
		and ic.column_id = c.column_id 

where i.type_desc = 'CLUSTERED' 


select 
	t.name as [Table], 
	i.name as [Index], 
	c.name as [Column],
	ic.key_ordinal as [Key]

into #non   

from 
	sys.indexes as i 

	inner join sys.tables as t 
	on i.object_id = t.object_id 
		and t.is_ms_shipped = 0 

	inner join sys.index_columns as ic 
	on i.object_id = ic.object_id 
		and i.index_id = ic.index_id 
		and ic.is_included_column = 0 

	inner join sys.columns as c 
	on ic.object_id = c.object_id 
		and ic.column_id = c.column_id 

where i.type_desc = 'NONCLUSTERED' 


select 
	db_name() as [Database],
	c.[Table], 
	c.[Index] as [Clustered Index], 
	c.[Column] as [Clustered Index Column],
	c.[Key] as [Clustered Index Key],
	n.[Index] as [Non-Clustered Index], 
	n.[Column] as [Non-Clustered Index Column],
	n.[Key] as [Non-Clustered Index Key]

from 
	#clust as c 

	left join #non as n 
	on c.[Table] = n.[Table] 
		and c.[Column] = n.[Column]
		and c.[Key] = n.[Key]  

where 
	n.[Index] is not null 
	and db_name() not in ('tempdb', 'master', 'msdb', 'model', 'ReportServer', 'ReportServerTempDB')

drop table 
	#clust, 
	#non 