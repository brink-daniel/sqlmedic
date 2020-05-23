/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Jun 2017</Date>
	<Title>Create and restore from database snapshot</Title>
	<Description>Use the CREATE DATABASE statement to create a database snapshot (read-only, static view) of the source database. A database snapshot is transactionally consistent with the source database as it existed at the time when the snapshot was created. A source database can have multiple snapshots. The source database can be restored from one of its snapshots.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Example</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



use master
go


--create new snapshot
declare 
	@source_database varchar(250) = 'DatabaseABC',
	@snapshot_store varchar(250) = 'D:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA',
	@sql nvarchar(4000),
	@logical_name varchar(250),
	@snapshot_name varchar(250)
	
	
--assumes source db only has one data file
select
	@logical_name = name
from sys.master_files
where 
	type_desc = 'ROWS'
	and database_id = db_id(@source_database)
	
	
set @snapshot_name = @source_database + '_Snapshot_' + replace(replace(replace(replace(convert(varchar(50), getdate(), 21), ' ', ''), ':', ''), '-', ''), '.', '')
	
	
set @sql = '
	create database [' + @snapshot_name  + ']
	on (name = ' + @logical_name + ', filename = ''' + @snapshot_store + '\' + @snapshot_name + '.ss'')
	as snapshot of [' + @source_database + ']
'
exec (@sql)
	


--restore from snapshot
restore database DatabaseABC FROM DATABASE_SNAPSHOT ='DatabaseABC_Snapshot_20170611160720130'

