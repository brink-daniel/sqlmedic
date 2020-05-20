/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Inline table valued user defined function</Title>
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


create or alter function dbo.GetData
(
	@startDate datetime,
	@endDate datetime
)
returns table
with schemabinding
as
return
	--must be single statement
	select
		column1
	from TableX
	where column1 between @startDate and @endDate;
go

--notes:
-- non-deterministic function are allowed in UDF as long as they do not have any side effects on the system
-- newid() and rand() not allowed in UDF
-- workaround: place side effecting function in a view and call the view from the UDF