/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Nov 2020</Date>
	<Title>Send asynchronous messages between SQL instances</Title>
	<Description>Create two-way asynchronous communication between two SQL instances using the Service Broker.</Description>
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

-- Run script on two SQL instances to create the objects needed for 
-- two-way asynchronous communication using xml messages between 
-- the SQL instances

use master;
go

--Start listening for messages
create endpoint GenericEndPoint
	state = started
	as tcp ( listener_port = 4022 ) -- Change port number on second instance to 4023
	for service_broker (authentication = windows);
go

grant connect on endpoint::GenericEndPoint to [DOMAIN\USER]; ---Change this to the service account used to run the SQL service
go

create database Demo;
go

alter database Demo set  enable_broker;
go

use Demo;
go


--table to hold all messages received
create table dbo.GenericMessages (
	MessageID int identity(1,1) constraint PK_GenericMessages primary key
	,Received datetime
	,Processed datetime
	,Body xml
);
go

--procedure to receive message from the queue and insert them into the dbo.GenericMessages table
create procedure dbo.ProcessGenericMessageQueue
as
begin
	declare 
		@handle uniqueidentifier, 
		@body varbinary(max), 
		@received datetimeoffset;

	waitfor (
		receive top (1)  
			@body = message_body
			,@handle = conversation_handle
			,@received = message_enqueue_time
		from dbo.GenericQueue
	), timeout 500 --milliseconds

	if (@@rowcount != 0)
	begin
		if @body is not null
		begin
			begin try
				insert into dbo.GenericMessages (Received, Processed, Body)
				select
					convert(datetime, switchoffset(@received, datepart(tzoffset,sysdatetimeoffset()))) as Received
					, getdate() as Processed
					, cast(@body as xml) as Body
			end try
			begin catch
				declare 
					@error int = error_number()
					, @message nvarchar(4000) = error_message();

				end conversation @handle with error = @error description = @message;
				return;
			end catch
		end

		end conversation @handle;
	end		
end
go


--define message structure
create message type GenericXmlMessageType validation=well_formed_xml;
go

--define messaging rules
create contract GenericContract ( GenericXmlMessageType sent by any);
go

--create queue to hold all messages reveived via the service broker
--also set the name of procedure that will process the queue
create queue GenericQueue with 
status = on 
, activation (
	status = on
	, max_queue_readers = 10 --number of instances of ProcessGenericMessageQueue
	, procedure_name = dbo.ProcessGenericMessageQueue
	, execute as owner
); 
go

--expose the queue via the service broker
create service GenericService on queue GenericQueue (GenericContract);
go

--define network location of outbound messages to the generic service
create route GenericRoute with service_name = 'GenericService', address = 'tcp://127.0.0.1:4023'; --Change this port number to 4022 on the second instance
go

grant send on service::GenericService to public;
go



--send message 
begin transaction
	declare @handle uniqueidentifier;

	begin dialog @handle
	from service GenericService
	to service 'GenericService'
	on contract GenericContract
	with encryption=off;

	send on conversation @handle message type GenericXmlMessageType ('<hello>world</hello>');
commit transaction
go





--debug
select * from dbo.GenericQueue
select * from sys.transmission_queue 
select * from dbo.GenericMessages
-- also check IP addresses, port numbers and firewall rules
go



