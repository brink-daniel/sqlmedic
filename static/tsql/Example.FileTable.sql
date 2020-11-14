/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>14 Nov 2020</Date>
	<Title>Create FileTable</Title>
	<Description>Create a SMB shared folder that appears as a table in SQL. Adding, updating or removing rows from the table, adds, updates and removes files from the folder and vice versa.</Description>
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


--1: Use the SQL Configuration Manager utility to enable FileStream for the SQL engine service
--- Enable FILESTREAM for Transact-SQL access
--- Enable FILESTREAM for file I/O access
--- Set the Windows share name
--- Enable remote clients access to FILESTREAM data

--2: Create a new database. Then in the database properties:
--- Add a FILESTREAM file group
--- Add a database file which uses the FILESTREAM file group
--- Set the FILESTREAM Directory name
--- Set FILESTREAM Non-Transacted Access to Full

--3: Create file table

CREATE TABLE [dbo].[Documents] AS FILETABLE ON [PRIMARY] FILESTREAM_ON [FILESTREAM_FG]
WITH
(
FILETABLE_DIRECTORY = N'Documents', FILETABLE_COLLATE_FILENAME = SQL_Latin1_General_CP1_CI_AS
)
GO

--4: Browse to \\localhost to see the SMB share

--5: Interact with the table to create, update and delete files in the SMB share


select * from Documents
GO

insert into Documents (file_stream, name)
select 
	cast('Hello' as varbinary(max))
	,'world.txt'
GO


select
	name
	,cast(file_stream as varchar(max)) as content
from Documents 
GO


update Documents 
set
	file_stream = cast('Test123' as varbinary(max))
where name = 'world.txt'
GO



begin tran

insert into Documents (file_stream, name)
select cast('Daniel' as varbinary(max)), 'Brink.txt'

--rollback tran
commit tran
GO


create table Documents_Log (
	TimeStamp datetime2
	,Action char(1)
	,PathLocator hierarchyid
)
go



create trigger Documents_Insert
on Documents
after insert
as
begin
	insert into Documents_Log(TimeStamp, Action, PathLocator)
	select
		SYSDATETIME()
		,'I'
		,path_locator
	from inserted
end
go


create trigger Documents_Update
on Documents
after update
as
begin
	insert into Documents_Log(TimeStamp, Action, PathLocator)
	select
		SYSDATETIME()
		,'U'
		,path_locator
	from inserted
end
go

create trigger Documents_Delete
on Documents
after delete
as
begin
	insert into Documents_Log(TimeStamp, Action, PathLocator)
	select
		SYSDATETIME()
		,'D'
		,path_locator
	from deleted
end




select * from Documents_Log
GO

--6: Interact with the files in the SMB share to insert, update and delete rows in SQL
