/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>25 Nov 2013</Date>
	<Title>Logins with admin rights</Title>
	<Description>Logins that belong to the server admin roles have elevated rights. These users have permission to do nearly anything they like on the server, including erasing their tracks. It is recommended to only grant users the specific rights they require and have no more than 3 admin logins. Do not grant admin rights unless absolutely required.</Description>
	<Pass>No logins with admin rights found.</Pass>	
	<Fail>{x} login(s) with admin rights found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Security</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

if (

	select
		count(*)
	from 
		master.sys.syslogins as l

		left join master.sys.sql_logins as s
		on l.[sid] = s.[sid]

	where
		(
			l.sysadmin = 1
			or l.securityadmin = 1
			or l.serveradmin = 1
			or l.setupadmin = 1
			or l.processadmin = 1
			or l.diskadmin = 1
			or l.dbcreator = 1
			or l.bulkadmin = 1
		)	
		and l.denylogin = 0
		and l.hasaccess = 1
		and isnull(s.is_disabled, 0) = 0

	

) > 3
begin

	select 
		l.name as [Login],
		case 
			when l.sysadmin = 1 then 'sysadmin'
			when l.securityadmin = 1 then 'securityadmin'
			when l.serveradmin = 1 then 'serveradmin'
			when l.setupadmin = 1 then 'setupadmin'
			when l.processadmin = 1 then 'processadmin'
			when l.diskadmin = 1 then 'diskadmin'
			when l.dbcreator = 1 then 'dbcreator'
			when l.bulkadmin = 1 then 'bulkadmin'
		end as [Server Role],
		l.createdate as [Created],
		l.updatedate as [Updated]
		
	from 
		master.sys.syslogins as l
		
		left join master.sys.sql_logins as s
		on l.[sid] = s.[sid]
		
	where
		(
			l.sysadmin = 1
			or l.securityadmin = 1
			or l.serveradmin = 1
			or l.setupadmin = 1
			or l.processadmin = 1
			or l.diskadmin = 1
			or l.dbcreator = 1
			or l.bulkadmin = 1
		)	
		and l.denylogin = 0
		and l.hasaccess = 1
		and isnull(s.is_disabled, 0) = 0
	
	order by
		l.name	

end