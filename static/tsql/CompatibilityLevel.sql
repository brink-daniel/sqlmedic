
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jan 2014</Date>
	<Title>Database compatibility level</Title>
	<Description>The database compatibility level of all databases should be set to be the same as the model database. This is to ensure consistent behaviour across all databases.</Description>
	<Pass>All databases have the same compatibility level as the model database.</Pass>	
	<Fail>{x} database(s) have inconsistent compatibility levels set.</Fail>
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
	convert(varchar(250), d.[compatibility_level]) + isnull(' ('
	+ case d.[compatibility_level]
		when 60 then 'SQL Server 6.0'
		when 65 then 'SQL Server 6.5'
		when 70 then 'SQL Server 7.0'
		when 80 then 'SQL Server 2000'
		when 90 then 'SQL Server 2005'	
		when 100 then 'SQL Server 2008 | 2008 R2'
		when 110 then 'SQL Server 2012'
		when 120 then 'SQL Server 2014'
		when 130 then 'SQL Server 2016'
		when 140 then 'SQL Server 2017'
		else null
	  end		
	+ ')', '') as [Database compatibility level],
	(
		select 
			convert(varchar(250), m.[compatibility_level]) + isnull(' ('
			+ case m.[compatibility_level]
				when 60 then 'SQL Server 6.0'
				when 65 then 'SQL Server 6.5'
				when 70 then 'SQL Server 7.0'
				when 80 then 'SQL Server 2000'
				when 90 then 'SQL Server 2005'	
				when 100 then 'SQL Server 2008 | 2008 R2'
				when 110 then 'SQL Server 2012'
				when 120 then 'SQL Server 2014'
				when 130 then 'SQL Server 2016'
				when 140 then 'SQL Server 2017'
				else null
			  end		
			+ ')', '')
		from sys.databases as m
		where m.name = 'model'
	) as [Server default compatibility level]

from sys.databases as d
where
	d.[compatibility_level] <> (select m.[compatibility_level] from sys.databases as m where name = 'model')
	and state_desc = 'ONLINE'