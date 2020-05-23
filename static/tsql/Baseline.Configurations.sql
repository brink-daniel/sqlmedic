/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Configurations</Title>
	<Description>Server configuration options</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_Configuration</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select
	getdate() as [TimeStamp],
	@@servername as [Server],
	configuration_id,
	name,
	value,	
	value_in_use
from sys.configurations