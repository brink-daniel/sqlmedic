/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Sequences</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Template</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/





create sequence BookID 
	as int
	start with 1
	increment by 1
	minvalue 1
	no maxvalue
	no cycle
	cache 50; 


select * from sys.sequences; 

select 
	(next value for BookID) as BookID,
	(next value for BookID) as BookID2

--NEXT VALUE FOR function is not allowed in 
-- check constraints, 
-- default objects, 
-- computed columns, 
-- views, 
-- user-defined functions, 
-- user-defined aggregates, 
-- user-defined table types, 
-- sub-queries, 
-- common table expressions, 
-- derived tables 
--or return statements.



create table [Library] (
	BookID int,
	Title varchar(250)
)


insert into [Library] (BookID, Title)
values 
	((next value for BookID), 'Hello world'), 
	((next value for BookID), 'Daniel Brink')

select * from [Library]


drop sequence BookID;
drop table [Library]