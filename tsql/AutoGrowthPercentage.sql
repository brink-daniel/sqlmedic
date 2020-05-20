/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Sep 2015</Date>
	<Title>Auto-growth configured as percentage</Title>
	<Description>It is not recommended to configure files to grow in size as percentage of the current file size as an auto grow event may trigger a file to grow by an excessively large amount of size which can fill up the HDD or take a long time to complete.</Description>
	<Pass>No data or logs files are configured to grow in size as a percentage of the current file size.</Pass>	
	<Fail>{x} data or logs file(s) are configured to grow in size as a percentage of the current file size.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	d.name as [Database],
	f.physical_name as [File],
	f.type_desc as [Type],
	convert(decimal(26,3), ((f.size * 8.0) / 1024.0) / 1024.0) as [Size (GB)],
	f.growth as [Growth (%)],	
	case when f.max_size > 0 then convert( decimal(26,3), ((f.max_size * 8.0) / 1024.0) / 1024.0) else null end	as [Max Size (GB)]
	
from 
	sys.databases as d

	inner join sys.master_files as f
	on d.database_id = f.database_id
		and f.is_percent_growth = 1
		and f.type in (0, 1) --rows or log

where d.name not in ('master', 'msdb', 'model', 'tempdb', 'ReportServer', 'ReportServerTempDB')

order by
	d.name,
	f.physical_name