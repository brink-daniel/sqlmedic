/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Jan 2014</Date>
	<Title>Job owner</Title>
	<Description>All SQL Agent Jobs should be owned by an account with limited rights or the system administrator (sa) account. The sid (0x01) of the sa account is always the same across all SQL Server instances, thus setting the job owner to sa makes it easy to move the job to another instance. This also allows user specific logins to be removed when a user leaves the company. It is however a huge security risk to have the owner of SQL Agent jobs set as the system administrator. Jobs execute within the context of the job owner and it is therefore recommended to set the owner on all jobs to a limited account with only the specific rights required.</Description>
	<Pass>All jobs are owned by a limited account or the sa account.</Pass>	
	<Fail>{x} jobs are not owned by a limited account or the sa account.</Fail>
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

if convert(varchar(250), (select serverproperty('edition'))) not like '%Express%'
begin

	select 
		name as [Job],
		suser_sname(owner_sid) [Owner]
	from msdb..sysjobs
	where
		suser_sname(owner_sid) not like '%SQLReportingServices'
		and [description] not like 'This job is owned by a report server process.%'
		and (		
			suser_sname(owner_sid) <> 'sa'
			and suser_sname(owner_sid) in (
				select
					ls.name
				from 
					sys.server_role_members as m					
			    
					inner join sys.server_principals as ls
					on m.member_principal_id = ls.principal_id
			)		
		)

	order by
		name




end