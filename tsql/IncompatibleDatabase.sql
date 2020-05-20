/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>07 Nov 2014</Date>
	<Title>SQL Medic: Database Compatibility</Title>
	<Description>SQL Medic only supports MS SQL 2005 SP2 and later editions. SQL Medic will work with earlier editions, but some checks will be skipped.</Description>
	<Pass>All databases on this SQL Server instance are compatible with SQL Medic.</Pass>	
	<Fail>{x} database(s) have a compatibility level of less than 90.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Compatibility</Category>
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
				else null
			  end		
			+ ')', '')
		from sys.databases as m
		where m.name = 'model'
	) as [Server default compatibility level]

from sys.databases as d
where
	d.state_desc = 'ONLINE'
	and d.[compatibility_level] < 90