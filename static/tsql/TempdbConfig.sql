/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>13 Jan 2014</Date>
	<Title>TempDB configuration</Title>
	<Description>The size and auto-growth settings of the tempdb data files should be the same to ensure optimal performance.</Description>
	<Pass>All tempdb data files are configured the same.</Pass>	
	<Fail>The tempdb data files are not configured consistently.</Fail>
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

select 
	name as [Logical name],
	physical_name as [Path],
	size * 8.0 / 1024.0 as [Size (MB)],
	 case growth
		when 0 then 'None'
		else			
			'By '  
			+ case is_percent_growth
				when 1 then convert(varchar(250),growth) + ' percent, '
				else convert(varchar(250), growth * 8 / 1024) + ' MB, '
			end 
			+ isnull('restricted growth to ' + convert(varchar(250), nullif(max_size, -1) * 8 / 1024) + ' MB', 'unrestricted growth')
	end		
	as [Autogrowth]
			
from tempdb.sys.database_files
where
	type_desc = 'ROWS'
	and exists (
		select top 1
			name
		from tempdb.sys.database_files
		where
			type_desc = 'ROWS'
			and 1 = case
						when
							size <> (select max(size) from tempdb.sys.database_files where type_desc = 'ROWS')
							or growth <> (select max(growth) from tempdb.sys.database_files where type_desc = 'ROWS')
							or convert(int, is_percent_growth) <> (select max(convert(int, is_percent_growth)) from tempdb.sys.database_files where type_desc = 'ROWS')
						then 1
						else 0
					end
	)
	

order by
	name
	