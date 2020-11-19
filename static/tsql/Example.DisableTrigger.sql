/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>20 Nov 2020</Date>
	<Title>Ignore triggers for a specific statement</Title>
	<Description>Use the CONTEXT_INFO to disable and enable triggers for specific statements. This method is faster than DDL commands to enable and disable triggers and also will not affect other queries.</Description>
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


drop table if exists MyTable, MyTable_Audit
go

create table MyTable (
	Column1 int
);
go

create table MyTable_Audit (
	[TimeStamp] datetime not null default(getdate())
	,[Action] char(1)
	,Column1 int
)
go

create trigger dbo.MyTable_Audit_IUD 
on dbo.MyTable
for insert, update, delete
as
begin
	--check if tigger should be executed
	--0x5 is just a random value, pick any value that is not already used by your system
	if context_info() = 0x5
		return;

	insert into dbo.MyTable_Audit ([Action], Column1)
	select
		'D' as [Action]
		, Column1
	from deleted;

	insert into dbo.MyTable_Audit ([Action], Column1)
	select
		'I' as [Action]
		, Column1
	from inserted;

end
go


insert into MyTable(Column1)
values (1)


set context_info 0x5 --disable triggers
insert into MyTable(Column1)
values (2)
set context_info 0x0 --enable triggers

insert into MyTable(Column1)
values (3)


select * from MyTable
select * from MyTable_Audit 

--read more about CONTEXT_INFO here:
--https://docs.microsoft.com/en-us/sql/t-sql/functions/context-info-transact-sql?view=sql-server-ver15
