/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Jul 2020</Date>
	<Title>Disable Jobs</Title>
	<Description>Generate script to disable all SQL Agent jobs.</Description>
	<Pass></Pass>
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Administration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


select
	'exec msdb..sp_update_job @job_name = ''' + name + ''', @enabled = 0;' 
from msdb..sysjobs
order by name