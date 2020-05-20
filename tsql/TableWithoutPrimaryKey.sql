/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>22 Apr 2015</Date>
	<Title>Table without primary key</Title>
	<Description>Primary keys allow SQL to uniquely identify rows in a table. This can aid query performance and is considered good design practice.</Description>
	<Pass>All tables have a primary key defined.</Pass>	
	<Fail>{x} table(s) found without a primary key.</Fail>
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
	t.name as [Table] 
			 
from 
	sys.tables as t
	
	left join sys.key_constraints as k
	on t.[object_id] = k.[parent_object_id]
		and k.[type] = 'PK'

where 
	k.name is null
	and db_name() not in ('tempdb', 'master', 'msdb', 'model', 'ReportServer', 'ReportServerTempDB')



