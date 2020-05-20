/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>23 Nov 2016</Date>
	<Title>Query default trace</Title>
	<Description>Query the contents of the default trace</Description>
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


set transaction isolation level read uncommitted

select top 1000 
	* 
from fn_trace_gettable((select top 1 [path] from sys.traces  where is_default = 1), default) 
--where TextData is not null
order by StartTime desc