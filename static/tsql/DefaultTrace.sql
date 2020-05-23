/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Sep 2015</Date>
	<Title>Default trace</Title>
	<Description>Check to see if the default trace is enabled and running.</Description>
	<Pass>The default trace is configured and running.</Pass>	
	<Fail>Default trace not found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


select
	case 
		when exists (select * from sys.configurations where name = 'default trace enabled') then 'Configured'
		else 'Not configured'
	end as [sys.configurations],
	case
		when exists (select * from sys.traces where is_default = 1) then 'Running'
		else 'Not running'
	end as [sys.traces]

where
	case 
		when exists (select * from sys.configurations where name = 'default trace enabled') then 1
		else 0
	end = 0
	or case
		when exists (select * from sys.traces where is_default = 1) then 1
		else 0
	end = 0