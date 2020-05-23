/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Apr 2015</Date>
	<Title>Logins with bad password</Title>
	<Description>All SQL logins must have a password which is not blank are the same as the login name. This script required CONTROL SERVER or sysadmin rights.</Description>
	<Pass>No logins with a blank password or a password matching the login name was found.</Pass>	
	<Fail>{x} login(s) with a blank password or a password matching the login name was found.</Fail>
	<Check>true</Check>
	<Advanced>true</Advanced>
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
	name as [Login]
from sys.sql_logins 
where
	is_disabled = 0
	and (
		pwdcompare(name, password_hash) = 1 
		or pwdcompare('', password_hash) = 1
	)