
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>27 May 2017</Date>
	<Title>Dedicated Administrator Connection (DAC)</Title>
	<Description>The DAC allows an administrator to access a running instance of SQL Server Database Engine to troubleshoot problems on the server—even when the server is unresponsive to other client connections</Description>
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




--see current server configurations
--exec sp_configure
select 
	name,
	value_in_use
from sys.configurations
where name = 'remote admin connections'
go


--enable remote dedicated administrator connection (DAC)
--DAC can only be used locally on the server if this option is disabled
exec sp_configure 'remote admin connections', 1 
go
reconfigure
go


--view the error log to get the port on which SQL in listening for incoming DAC 
--this will normally be port 1434 (not 1433 which is the default port for normal SQL connections by TCP)
--this port will have to be opened in your server firewall
exec sp_readerrorlog 0, 1
go


--a DAC connection can be opened using SSMS query window (note server explorer is not supported, as there can only be one DAC open at a time)
-- prefix the server name with "admin:" to open a DAC

--see who is hogging the DAC
select
	*
	
from 
	sys.endpoints as e

	inner join sys.dm_exec_sessions as s 
	on e.endpoint_id = s.endpoint_id

where e.name = 'Dedicated Admin Connection'
	
	
