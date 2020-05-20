
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>18 Mar 2015</Date>
	<Title>Low fill factor</Title>
	<Description>Lowering the fill factor on index pages does reduce slow page splits (fragmentation) when modifying data, but it reduces the amount of data which can be cached into RAM as the page size will always require 8KB irrespective of how full it is.</Description>
	<Pass>All indexes have a fill factor or 80% or higher.</Pass>	
	<Fail>{x} indexes found with a fill factor of less than 80%.</Fail>
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
	db_name() as [Database],
	t.name as [Table],
	i.name as [Index],
	i.fill_factor as [Fill Factor]
	
from 
	sys.indexes as i
	
	inner join sys.tables as t
	on i.[object_id] = t.[object_id]

where
	i.fill_factor > 0
	and i.fill_factor < 80
	and db_name() not in ('tempdb', 'master', 'msdb', 'model', 'ReportServer', 'ReportServerTempDB')