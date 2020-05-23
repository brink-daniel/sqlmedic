/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jan 2013</Date>
	<Title>Missing indexes</Title>
	<Description>Review the execution plans of all queries accessing these tables and create suitable indexes to enhance performance.</Description>
	<Pass>No missing indexes reported by the query optimizer.</Pass>	
	<Fail>The query optimizer reported that there are {x} missing indexes.</Fail>
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


select
	db_name(d.database_id) as [Database],
	object_name(d.[object_id], d.database_id) as [Table],
	d.equality_columns as [Equality columns],
	d.inequality_columns as [Inequality columns],
	d.included_columns as [Included columns],
	s.unique_compiles as [Unique compiles],
	s.user_seeks as [User seeks],
	s.user_scans as [User scans],
	s.avg_total_user_cost as [Avg. total user cost],
	s.avg_user_impact as [Avg user impact]	
from 
	sys.dm_db_missing_index_group_stats as s
		
	inner join sys.dm_db_missing_index_groups as g
	on s.group_handle = g.index_group_handle
	    
	inner join sys.dm_db_missing_index_details as d
	on g.index_handle = d.index_handle

order by
	s.avg_total_user_cost * s.avg_user_impact  * (s.user_seeks + s.user_scans) desc