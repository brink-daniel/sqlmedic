/* 
<Script> 
    <Author>Daniel Brink</Author> 
    <Date>16 Dec 2014</Date> 
    <Title>Stale index statistics</Title> 
    <Description>Index statistics are a collection of data that describe more details about the database and the objects in the database. These statistics are used by the query optimizer to choose the best execution plan for each SQL statement. Stale Statistics may cause the Query Optimizer to generate poor execution plans that may result in poor performance. Indexes in this report have not been updated in the past 7 days.</Description> 
    <Pass>No indexes were found were found with outdated statistics.</Pass>     
    <Fail>{x} index(es) were found with outdated statistics.</Fail> 
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
    db_name() as [database],
    o.name as [table],
    s.name as [statistic],
    sp.rows,
    sp.modification_counter,
    cast((sp.modification_counter * 1.0 / sp.rows) * 100.0 as decimal(18,2)) as [% change],
    sp.last_updated
      

from 
    sys.stats as s

    inner join sys.objects as o
    on s.object_id = o.object_id
	   and is_ms_shipped = 0

    cross apply sys.dm_db_stats_properties(s.object_id, s.stats_id) as sp

where 
    --contains more than 1000 rows
    sp.rows > 1000
    --has changes
    and sp.modification_counter > 0
    --last refreshed more than 7 days ago
    and sp.last_updated <= dateadd(day, -7, getdate()) 
    

order by  [% change] desc