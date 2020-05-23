/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Auto Batch ID</Title>
	<Description></Description>
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


set nocount on

create table #temp (
	id int identity (1,1), --auto id required
	batch as (id / 100), --set batch size
	value varchar(50)
)

--generate some test data
while ((select count(*) from #temp) < 149)
begin
	insert into #temp (value)
	values ('hello')
end

--see batch column
select * from #temp

drop table #temp