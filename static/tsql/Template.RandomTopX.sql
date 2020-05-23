/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Top</Title>
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



--Top X rows

select top (3)
	column1,
	column2
from TableX
order by (select null); --tell other devs that the omission of ordering was on purpose
