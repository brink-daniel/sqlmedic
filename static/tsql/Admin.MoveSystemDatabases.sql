/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>03 Nov 2020</Date>
	<Title>Move System Databases</Title>
	<Description>Steps to move the master, msdb, model and tempdb databases to a new location.</Description>
	<Pass></Pass>
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Administration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


/*
Step 1: Create new folder. 
Grant the service account, the one which is used to run the SQL services, full access to the new folder.
If you are using the built in default service accounts, the account name might be something like MSSQLSERVER, or MSSQL$INSTANCE
Check the security settings on the current folder for the service account name.

*/


/*
Step 2: Update database paths
*/


use master
go

declare 
	@current_path varchar(250) = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\'
	,@new_path varchar(250) = 'S:\DATA\';

declare @sql nvarchar(max) = ''
select 
	@sql = @sql + 'ALTER DATABASE ' + db_name(database_id) +  ' MODIFY FILE (NAME = ' + name + ', FILENAME = ''' + replace(physical_name, @current_path, @new_path) + ''');' + char(13) 
from sys.master_files 
where database_id in (db_id('master'), db_id('msdb'), db_id('model'), db_id('tempdb'));


print @sql;
exec (@sql);
go


/*
Step 3: Stop the SQL Engine and SQL Agent services
*/

/*
Step 4: Use RegEdit to update the path for the "SQLDataRoot" key
*/

/*
Step 5: Delete the tempdb files from the old/current location. TempDB files will be recreated in the new location when SQL is started.
*/

/*
Step 6: Move the master, msdb and model files to the new location
*/

/*
Step 7: For the SQL Server service, correct the path in the Startup Parameters using the SQL Server Configuration Manager.
*/

/*
Step 8: Start SQL Server
*/





