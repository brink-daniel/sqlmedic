/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Multi-statement table valued user defined function</Title>
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
returns @data table (
	id int
)
with schemabinding
as
begin

	declare @id int;

	select top 1
		@id 
	from TableX
	where column1 between @startDate and @endDate
	order by column2 desc;
	
	insert into @data (id)
	values (@id);
	
	
	return;
		
		
end;

--notes:
-- non-deterministic function are allowed in UDF as long as they do not have any side effects on the system
-- newid() and rand() not allowed in UDF
-- workaround: place side effecting function in a view and call the view from the UDF