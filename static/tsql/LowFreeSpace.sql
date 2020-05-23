/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Sep 2015</Date>
	<Title>Low free space in file</Title>
	<Description>SQL Server requires free space in data in log files to complete data modification commands. The command will fail if there is no free space in the file or if SQL Server is not configured to increase the file size. Increasing the file size is known as an auto-grow event. Auto-growth events can take a long time to complete based on the size of the file change.</Description>
	<Pass>All files have sufficient free space</Pass>	
	<Fail>{x} files found with low free space.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select				
	db_name() as [Database],	
	[physical_name] as [File],
	type_desc as [Type],
	(cast([size] as decimal(38,0))/128) - (cast(fileproperty([name],'SpaceUsed') as decimal(38,0))/128.0) as [Free space (MB)],	
	case
		when is_percent_growth = 1 then
			(cast([size] as decimal(38,0))/128) * (growth / 100.0)
		else
			(growth * 8.0) / 1024.0
	end as [Next growth (MB)]

from sys.database_files
where
	[type] in (0, 1) -- data or log
	and growth > 0
	and 
	(
	(cast([size] as decimal(38,0))/128) - (cast(fileproperty([name],'SpaceUsed') as decimal(38,0))/128.0)
	< case
		when is_percent_growth = 1 then
			(cast([size] as decimal(38,0))/128) * (growth / 100.0)
		else
			(growth * 8.0) / 1024.0
	end * 0.8
	or (cast([size] as decimal(38,0))/128) - (cast(fileproperty([name],'SpaceUsed') as decimal(38,0))/128.0) < 128
	)