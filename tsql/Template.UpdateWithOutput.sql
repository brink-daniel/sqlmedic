/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Update with Output</Title>
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


update Test99
set
	column1 = 'hi'
output --only access to target table in output
	inserted.id,
	inserted.column1,
	deleted.column1
	into Test101 (id, column1, column2) 
output
	inserted.id,
	inserted.column1,
	deleted.column1
where id = 7