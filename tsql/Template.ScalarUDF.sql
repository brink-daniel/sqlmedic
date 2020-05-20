
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Scalar user defined function</Title>
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




create or alter function dbo.AddNumbers
(
	@num1 int,
	@num2 int = 5
)
returns int
with schemabinding
as
begin
	declare @result int;
	
	set @result = @num1 + @num2;
	
	return @result	

end;
go


select dbo.AddNumbers(2,5), dbo.AddNumbers(2,default)


--notes:
-- non-deterministic function are allowed in UDF as long as they do not have any side effects on the system
-- newid() and rand() not allowed in UDF
-- workaround: place side effecting function in a view and call the view from the UDF