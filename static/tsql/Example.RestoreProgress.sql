

/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>30 Sep 2019</Date>
	<Title>Database Backup & Restore Progress</Title>
	<Description>See how long a database restore or backup that is in progress will take to finish.</Description>
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



select 
	session_id,
	command, 
	a.text, 
	start_time, 
	percent_complete,
	estimated_completion_time,
	dateadd(second,estimated_completion_time/1000, getdate()) as estimated_completion_time_2

from 
	sys.dm_exec_requests as r 

	cross apply sys.dm_exec_sql_text(r.sql_handle) as a

where r.command in ('BACKUP DATABASE','RESTORE DATABASE')