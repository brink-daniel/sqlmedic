


/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>30 Sep 2019</Date>
	<Title>Check if Job is running on the Primary instance</Title>
	<Description>Add the following as the first step in each job. If the step executes successfully, proceed to the next step. If the step fails, exit the job reporting success.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Always-On</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



if exists (select name from sys.databases where databasepropertyex(name, 'Updateability') <> 'READ_WRITE')
begin
	raiserror('Not writeable replica. Do no run job. Stop job gracefully on this step.', 16, 1);
end