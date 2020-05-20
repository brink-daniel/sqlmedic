/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2014</Date>
	<Title>Heaps</Title>
	<Description>Tables without clustered indexes as known as heaps. These tables allow for very fast data inserts, but data retrieval and updates would be very slow as the data is randomly scattered on the hard drive in no particular order.</Description>
	<Pass>No tables without a clustered index found.</Pass>	
	<Fail>{x} heaps found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Performance</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted



select
	db_name() as [Database],
	t.name as [Table]
			
from 
	sys.tables as t
			
	left join sys.indexes as i
	on t.[object_id] = i.[object_id]
		and i.type_desc = 'CLUSTERED'
			
where
	i.name is null --no clustered index found
	and db_name() not in ('tempdb', 'master', 'msdb', 'model', 'ReportServer', 'ReportServerTempDB')
			
order by			
	[Table]

		
