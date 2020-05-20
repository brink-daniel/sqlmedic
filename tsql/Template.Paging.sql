/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Offset fetch</Title>
	<Description>Implement server side paging using OFFSET ... FETCH</Description>
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



--Paging

declare
	@pageNum int = 3,
	@pageSize int = 20 

select
	column1,
	column2
from TableX
order by column1
offset (@pageNum -1) * @pageSize rows fetch next @pageSize rows only;
