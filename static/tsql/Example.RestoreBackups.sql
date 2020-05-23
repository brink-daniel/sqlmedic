/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>05 Jun 2016</Date>
	<Title>Restore all database backups from folder</Title>
	<Description>Note: This script assumes that each database only have one data and one log file.</Description>
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

use [master]

set nocount on

--define paths
declare 
	@backups varchar(250) = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup',
	@data varchar(250) = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA',
	@logs varchar(250) = 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA'


--get all database backups to restore
create table #dir (	
	subdirectory nvarchar(512),
	depth int,
	isfile bit
)

insert into #dir (subdirectory,depth,isfile)
exec master.dbo.xp_dirtree @backups, 1, 1


select
	subdirectory as path,
	substring(subdirectory, 0, charindex('_backup', subdirectory)) as db

into #tmp

from #dir 
where 
	subdirectory like '%.bak'
	--exclude databases you do not want to restore
	and subdirectory not like 'master%'
	and subdirectory not like 'model%'
	and subdirectory not like 'msdb%'
	and subdirectory not like 'tempdb%'
	and subdirectory not like 'ReportServer%'
	--do not restore over existing databases
	and substring(subdirectory, 0, charindex('_backup', subdirectory)) not in (select name from sys.databases) 


--build and exec the database restore script
create table #files (	
	LogicalName nvarchar(128),
	PhysicalName nvarchar(260),
	Type char(1),
	FileGroupName nvarchar(128),
	Size numeric(20,0),
	MaxSize numeric(20,0),
	FileId bigint,
	CreateLSN numeric(25,0),
	DropLSN numeric(25,0),
	UniqueId uniqueidentifier,
	ReadOnlyLSN numeric(25,0),
	ReadWriteLSN numeric(25,0),
	BackupSizeInBytes bigint,
	SourceBlockSize int,
	FileGroupId int,
	LogGroupGUID uniqueidentifier,
	DifferentialBaseLSN numeric(25,0),
	DifferentialBaseGUID uniqueidentifier,
	IsReadOnly bit,
	IsPresent bit,
	TDEThumbprint varbinary(32)
)



while exists (select * from #tmp)
begin
	declare 
		@db varchar(250) = '', 
		@p varchar(250) = ''

	select top 1
		@db = db,
		@p = [path]
	from #tmp
	order by db

	delete from #tmp where db = @db
	truncate table #files


	declare @sql nvarchar(3000) = ''

	select @sql = 'RESTORE DATABASE [' + @db + '] FROM  DISK = N''' + @backups + '\' + @p + ''' WITH  FILE = 1,
		'
	--get the logical file names
	insert into #files (LogicalName,PhysicalName,[Type],FileGroupName,
		Size,MaxSize,FileId,CreateLSN,DropLSN,UniqueId,ReadOnlyLSN,
		ReadWriteLSN,BackupSizeInBytes,SourceBlockSize,FileGroupId,
		LogGroupGUID,DifferentialBaseLSN,DifferentialBaseGUID,IsReadOnly,
		IsPresent,TDEThumbprint)
	exec ('RESTORE FILELISTONLY FROM DISK = N''' + @backups + '\' + @p + '''')

	while exists (select * from #files)
	begin
		declare @name varchar(250), @type varchar(250)

		select top 1 			
			@name = LogicalName,
			@type = [Type]
		
		from #files

		delete from #files where LogicalName = @name

		if @type = 'D' 
		begin
			set @sql += 'MOVE N''' + @name + ''' TO N''' + @data + '\' + @db + '.mdf'','
		end
		else
		begin
			set @sql += 'MOVE N''' + @name + ''' TO N''' + @logs + '\' + @db + '_log.ldf'','
		end
	end

	set @sql += 'STATS = 5
	
	'



	print @sql
	--exec (@sql)

end


drop table #tmp, #dir, #files


