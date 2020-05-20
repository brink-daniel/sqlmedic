/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Jan 2018</Date>
	<Title>Provision database</Title>
	<Description>Create a new filegroup and file to store user data separate from the schemas and data, the "PRIMAY" filegroup, created by SQL during the initial database creation</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>false</Foreachdb>
	<store></store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

use master;
go

--drop database Demo;
create database Demo;
go

alter database Demo add filegroup [User]
go

--never place files on C:
--this is just a demo 
alter database Demo add file (
	name = N'User', 
	filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\User.ndf'
) to filegroup [User]
go

alter database [Demo] modify filegroup [User] default
go
