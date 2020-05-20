/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Jul 2017</Date>
	<Title>Data Masking</Title>
	<Description>Define masked table columns and control UNMASK rights. Note all logins with sysadmin rights can unmask data and data can be guessed and extrapolated using range conditions. Masking is not a complete security solution.</Description>
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




--create a new table
create table Client (
       ClientID int identity(1,1) primary key,
       Name varchar(250),
       PhoneNumber varchar(250) masked with (function = 'default()'), --define a column as masked
       PostalAddress varchar(250) masked with (function = 'default()') --define a column as masked
)


--insert some sample data
insert into Client (Name, PhoneNumber, PostalAddress)
values ('Daniel Brink', '0435870000', 'Sydney, Australia')

--view the data
select * from Client



--create a user, this could be one of the devs, analysts, ...
create user Staff without login
grant select, insert, delete, update on Client to Staff

--when the Staff user queries data, the masked columns are obfuscated, but no data is actually changed
execute as user = 'Staff'
select * from Client
revert




--give the Staff user UNMASK rights
grant unmask to Staff

--now the Staff user can see the confidential data
execute as user = 'Staff'
select * from Client
revert


--and we can take the UNMASK rights away again 
revoke unmask to Staff




--Masking has no effect on the Staff users ability to use the Client table

execute as user = 'Staff'
insert into Client (Name, PhoneNumber, PostalAddress)
values ('Bob Smith', '34534252345', 'Wagga wagga, Australia')

select * from Client

revert

