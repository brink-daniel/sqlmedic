/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Computed column</Title>
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






create or alter function dbo.EndOfYear (
	@dt date
)
with schemabinding
as
begin
	return datefromparts(year(@dt), 12, 31);
end;

go


create table dbo.Table1 (
	ID int itendity(1,1) constraint PK_Table1 primary key,
	DT date,
	YearEnd as dbo.EndOfYear(DT) persisted
)

--notes
-- function used in computed column must be deterministic, else you cannot index the column