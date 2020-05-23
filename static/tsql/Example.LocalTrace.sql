/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Server Side Trace</Title>
	<Description>Start a server side trace and view results</Description>
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



--see all traces. There will always be at least 1 running -> the default trace. Please do not stop or edit the default trace, but you are welcome to query its contents.
select case [status] when 1 then 'Running' else 'Stopped' end as [State], * from sys.traces




--1. Create a new trace
declare 
       @traceID int, -- save the ID you'll need it later. I am using @traceID=2 in my examples below.
       @maxfilesize bigint = 5, -- NB: limit your trace file size to 5MB, else you risk filling the HDD if the trace runs for very long
       @stop datetime = dateadd(minute, 2, getdate()), -- auto stop and delete the trace 2 minutes after it has been created (not started)
       @path nvarchar(254) = 'c:\trace\dbr' --path to the trace file to be created. leave the .trc extension out (c:\trace\dbr.trc). SQL must have access rights to this folder.

exec sp_trace_create @traceID output,0, @path, @maxfilesize, @stop

--note your trace id
select * from sys.traces where id = @traceID



--2. Add events to listen for.
--https://msdn.microsoft.com/en-us/library/ms186265.aspx

--RPC:Completed = 10. Batches completing
declare @traceID int = 2
exec sp_trace_setevent @traceID, 10, 1 /*Text*/ , 1
exec sp_trace_setevent @traceID, 10, 13 /*Duration*/ , 1
exec sp_trace_setevent @traceID, 10, 16 /*Reads*/ , 1
exec sp_trace_setevent @traceID, 10, 17 /*Writes*/ , 1
exec sp_trace_setevent @traceID, 10, 18 /*CPU*/ , 1
exec sp_trace_setevent @traceID, 10, 34 /*ObjectName*/ , 1
exec sp_trace_setevent @traceID, 10, 35 /*DatabaseName*/ , 1

--SQL:BatchCompleted = 12. Stored procs executed
exec sp_trace_setevent @traceID, 12, 1 /*Text*/ , 1
exec sp_trace_setevent @traceID, 12, 13 /*Duration*/ , 1
exec sp_trace_setevent @traceID, 12, 16 /*Reads*/ , 1
exec sp_trace_setevent @traceID, 12, 17 /*Writes*/ , 1
exec sp_trace_setevent @traceID, 12, 18 /*CPU*/ , 1
exec sp_trace_setevent @traceID, 12, 34 /*ObjectName*/ , 1
exec sp_trace_setevent @traceID, 12, 35 /*DatabaseName*/ , 1


--3. (Highly advisable) Set a filter to limit the amount of data recorded.
--https://msdn.microsoft.com/en-us/library/ms174404.aspx
declare @traceID int = 2
exec sp_trace_setfilter @traceID, 35 /*DatabaseName*/, 0 /*AND*/, 6 /*LIKE*/, N'%DatabaseName%'
exec sp_trace_setfilter @traceID, 1 /*Text*/, 0 /*AND*/, 6 /*LIKE*/, N'%sp%'


--4. Start the trace
declare @traceID int = 2
exec sp_trace_setstatus @traceID, 1


--RUN stored procs / reports / web site / apps etc..



--5. Stop the trace 
declare @traceID int = 2
exec sp_trace_setstatus @traceID, 0


--6. Read the data you recorded
declare @traceID int = 2
select top 100 
       *
from fn_trace_gettable((select [path] from sys.traces where id = @traceID), default) 
where TextData is not null


--7. Delete the trace. 
declare @traceID int = 2
exec sp_trace_setstatus @traceID, 2


---Note. This does not delete the .trc file from the HDD, you can always go back and query your trace data again by accessing the file directly.


select top 100 
       *
from fn_trace_gettable('c:\Trace\dbr.trc', default) 
where TextData is not null



