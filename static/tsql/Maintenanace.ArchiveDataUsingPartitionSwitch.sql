/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>16 Jan 2018</Date>
	<Title>Archive data by switching partitions</Title>
	<Description>Switching partitions is much quicker than physically copying data from one table to another.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Maintenance</Category>
	<Foreachdb>false</Foreachdb>
	<store></store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


--create new archive table

create schema archive;
go

--drop table archive.Sales
create table archive.Sales (
	KeyID int identity(1,1) not null,
	[Date] datetime not null,
	/*
	other stuff
	*/
	constraint PK_Sales_KeyID primary key (KeyID, [Date])
) on [2017]
go

select * from fact.Sales
select * from archive.Sales
go


--see contents of partitions
select 
	s.name as [Schema],
	t.name as [Table],
	p.partition_number as [Partition],
	p.rows as [Rows]	

from 
	sys.tables as t

	inner join sys.schemas as s
	on t.schema_id = s.schema_id
		
	inner join sys.partitions as p 
	on t.object_id = p.object_id

where t.name = 'Sales' 
order by s.name, t.name, p.partition_number

/*
Schema	Table	Partition	Rows
archive	Sales	1			0
fact	Sales	1			365
fact	Sales	2			31
fact	Sales	3			28
fact	Sales	4			31
fact	Sales	5			30
fact	Sales	6			31
fact	Sales	7			30
fact	Sales	8			31
fact	Sales	9			31
fact	Sales	10			30
fact	Sales	11			31
fact	Sales	12			30
fact	Sales	13			31
fact	Sales	14			59
*/





--move old data to the archive table
alter table fact.Sales
switch partition 1 to archive.sales --source and destination partition must be in the same filegroup


--see new location of data by running the first query again
/*
Schema	Table	Partition	Rows
archive	Sales	1			365
fact	Sales	1			0
fact	Sales	2			31
fact	Sales	3			28
fact	Sales	4			31
fact	Sales	5			30
fact	Sales	6			31
fact	Sales	7			30
fact	Sales	8			31
fact	Sales	9			31
fact	Sales	10			30
fact	Sales	11			31
fact	Sales	12			30
fact	Sales	13			31
fact	Sales	14			59
*/


-- next tasks
--- remove empty partitions if no longer needed
--- adjust partitioning function and schema