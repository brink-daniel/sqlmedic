/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Apr 2015</Date>
	<Title>Control Server permission</Title>
	<Description>The CONTROL SERVER permission is meant to be a future replacement for the sysadmin server role, but its implementation is inconsistent. Logins with the CONTROL SERVER permission effectively have sysadmin rights, but will not be flagged as such by regular security checks. Users with CONTROL SERVER permission can also easily make themselves members of the sysadmin server role and/or cover any of there tracks.</Description>
	<Pass>No logins with CONTROL SERVER permission found.</Pass>	
	<Fail>{x} login(s) with CONTROL SERVER permission found.</Fail>
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


select
	l.name as [Login],
	l.type_desc as [Type],
	p.permission_name as [Permission],
	p.state_desc as [State]	
	
from 
	master.sys.server_permissions as p
	
	inner join master.sys.server_principals as l
	on p.grantee_principal_id = l.principal_id
		and l.is_disabled = 0	

where
	(
		state_desc = 'GRANT_WITH_GRANT_OPTION'
		or state_desc = 'GRANT'
	)
	and permission_name = 'CONTROL SERVER'
	and l.name != '##MS_PolicySigningCertificate##'
	



