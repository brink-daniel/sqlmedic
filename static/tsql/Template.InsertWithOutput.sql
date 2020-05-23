/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Insert with Output</Title>
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




insert into Test99 (column1, column2)
output --only access to target table in output
	inserted.id, inserted.column1, inserted.column2
	into Test100 (id, column1, column2) 
output
	inserted.id, inserted.column1, inserted.column2
select
	'hello' as column1,
	'world' as column2