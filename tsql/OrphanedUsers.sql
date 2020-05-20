/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Nov 2013</Date>
	<Title>Orphaned users</Title>
	<Description>A database user for which the corresponding SQL Server login is undefined or is incorrectly defined on a server instance cannot log in to the instance. Such a user is said to be an orphaned user of the database on that server instance. A database user can become orphaned if the corresponding SQL Server login is dropped. Also, a database user can become orphaned after a database is restored or attached to a different instance of SQL Server. Orphaning can happen if the database user is mapped to a SID that is not present in the new server instance.</Description>
	<Pass>No orphaned users found.</Pass>	
	<Fail>{x} orphaned user(s) found.</Fail>
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

create table #orphanedUsers (
	[Database] varchar(250),
	[OrphanedUser] varchar(250)
)


exec sp_msforeachdb '

insert into #orphanedUsers ([Database], [OrphanedUser])
select  
	''?'' as [Database], 
	su.Name as [OrphanedUser]	
from [?]..sysusers su
where
	su.islogin = 1
	and su.name not in (''guest'',''sys'',''INFORMATION_SCHEMA'',''dbo'', ''MS_DataCollectorInternalUser'')
	and not exists (
		select 
			*
		from master..syslogins as sl
		where su.[sid] = sl.[sid]
	)

option (recompile)

'


select 
	[Database], 
	[OrphanedUser] as [Orphaned user]
from #orphanedUsers
order by
	[Database], 
	[OrphanedUser]

drop table #orphanedUsers
		