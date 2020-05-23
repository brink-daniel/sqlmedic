/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>08 Oct 2017</Date>
	<Title>Table Valued Parameter (TVP)</Title>
	<Description>Create a new custom table data type for use as a parameter when calling a stored procedure.</Description>
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




---Create a new custom table data type
create type PersonObject as table (
	Firstname varchar(250),
	Lastname varchar(250)	
)
go





--Demo using custom data type as a parameter

--Create a demo table
create table Person (
	ID int identity(1,1) primary key,
	Firstname varchar(250),
	Lastname varchar(250),
	Active bit
)
go


--Create a stored procedure using the new custom data type
create or alter procedure InsertPerson
(
	@Active bit,
	@Person as dbo.PersonObject readonly, --table must be passed in as READONLY
	@ID int output

)
as
begin
	set xact_abort, nocount on
	
	insert into Person (Firstname, Lastname, Active)
	select
		Firstname, 
		Lastname,
		1 as Active
	
	from @Person

	set @ID = scope_identity()


end
go


--Example using our table valued parameter

declare 
	@p PersonObject, --declare a variable
	@ID int

--populate the variable
insert into @p (Firstname, Lastname)
values ('Daniel', 'Brink')

--pass variable to store proc as a parameter 
exec InsertPerson
	@Active = 1,
	@Person = @p, ---tvp
	@ID = @ID output

--results
select @ID as ID

select * from Person