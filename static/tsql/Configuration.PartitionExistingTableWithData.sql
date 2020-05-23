/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>17 Jan 2018</Date>
	<Title>Partition an existing table with data</Title>
	<Description>Apply partitioning on an existing table containing data by creating new filegroups, adding files to the filegroups, defining a partitioning function and schema and then lastly dropping and recreating the clustered index to physically move the data to the correct partitions.</Description>
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



--use master
--drop database Demo
--create database Demo
use Demo;
go


--create test data
create schema [fact];
go

--drop table fact.Sales
create table fact.Sales (
	KeyID int identity(1,1) constraint PK_Sales_KeyID primary key,
	[Date] datetime not null
	/*
	other stuff
	*/
)
go


declare @d datetime2 = '01 Jan 2017';
while @d < '01 Mar 2019'
begin
	insert into fact.Sales ([Date])
	values (@d);

	set @d = dateadd(day, 1, @d);
end
go

select * from fact.Sales;
go


--partition an existing table with data

--optional: create filegroups

alter database Demo add filegroup [2017];
alter database Demo add filegroup [2018_Jan];
alter database Demo add filegroup [2018_Feb];
alter database Demo add filegroup [2018_Mar];
alter database Demo add filegroup [2018_Apr];
alter database Demo add filegroup [2018_May];
alter database Demo add filegroup [2018_Jun];
alter database Demo add filegroup [2018_Jul];
alter database Demo add filegroup [2018_Aug];
alter database Demo add filegroup [2018_Sep];
alter database Demo add filegroup [2018_Oct];
alter database Demo add filegroup [2018_Nov];
alter database Demo add filegroup [2018_Dec];
alter database Demo add filegroup [2019];
go

--never place files on C:
--this is just a demo 
alter database Demo add file (name = N'2017', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2017.ndf') to filegroup [2017];

alter database Demo add file (name = N'2018_Jan', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Jan.ndf') to filegroup [2018_Jan];
alter database Demo add file (name = N'2018_Feb', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Feb.ndf') to filegroup [2018_Feb];
alter database Demo add file (name = N'2018_Mar', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Mar.ndf') to filegroup [2018_Mar];
alter database Demo add file (name = N'2018_Apr', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Apr.ndf') to filegroup [2018_Apr];
alter database Demo add file (name = N'2018_May', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_May.ndf') to filegroup [2018_May];
alter database Demo add file (name = N'2018_Jun', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Jun.ndf') to filegroup [2018_Jun];
alter database Demo add file (name = N'2018_Jul', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Jul.ndf') to filegroup [2018_Jul];
alter database Demo add file (name = N'2018_Aug', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Aug.ndf') to filegroup [2018_Aug];
alter database Demo add file (name = N'2018_Sep', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Sep.ndf') to filegroup [2018_Sep];
alter database Demo add file (name = N'2018_Oct', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Oct.ndf') to filegroup [2018_Oct];
alter database Demo add file (name = N'2018_Nov', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Nov.ndf') to filegroup [2018_Nov];
alter database Demo add file (name = N'2018_Dec', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2018_Dec.ndf') to filegroup [2018_Dec];

alter database Demo add file (name = N'2019', filename = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\2019.ndf') to filegroup [2019];
go



create partition function Monthly (datetime) 
as range right for values(
	'01 Jan 2018',
	'01 Feb 2018',
	'01 Mar 2018',
	'01 Apr 2018',
	'01 May 2018',
	'01 Jun 2018',
	'01 Jul 2018',
	'01 Aug 2018',
	'01 Sep 2018',
	'01 Oct 2018',
	'01 Nov 2018',
	'01 Dec 2018',
	'01 Jan 2019' ---!!!range right!!!
)
go

create partition scheme Monthly as partition Monthly to (
	[2017],
	[2018_Jan],
	[2018_Feb],
	[2018_Mar],
	[2018_Apr],
	[2018_May],
	[2018_Jun],
	[2018_Jul],
	[2018_Aug],
	[2018_Sep],
	[2018_Oct],
	[2018_Nov],
	[2018_Dec],
	[2019]
)
go

--move table from primary to new partitions by recreating the clustered index
alter table fact.Sales drop constraint PK_Sales_KeyID;
alter table fact.Sales add constraint PK_Sales_KeyID primary key (KeyID, [Date]) on Monthly([Date]);
-- or drop and create index if it was not add as a constraint
go


-- see in theory where the data should be
select 
	*, 
	$partition.Monthly([Date]) as [Partition] 
from fact.Sales;


-- see contents of partitions

select 
	t.name as [Table],
	p.partition_number as [Partition],
	p.rows as [Rows]	

from 
	sys.tables as t

	inner join sys.partitions as p 
	on t.object_id = p.object_id

where t.name = 'Sales'


 
