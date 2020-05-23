/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Feb 2014</Date>
	<Title>Agent alerts</Title>
	<Description>Disabled SQL Agent Alerts can indicate an error which is happening, but is being ignored.</Description>
	<Pass>No disabled alerts found.</Pass>	
	<Fail>{x} disabled alerts found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Stability</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


select 
	name as [Alert],
	[enabled] as [Enabled]
from msdb..sysalerts
where [enabled] = 0
order by
	name
