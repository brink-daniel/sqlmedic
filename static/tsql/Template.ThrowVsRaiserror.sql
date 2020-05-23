/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Throw vs Raiserror</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Template</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/




--throw

print 1;
throw 50000, 'test', 1;
print 2;


--preceding statement must be terminated
--error number must be >= 50000, does not have to be recorded anywhere
--stops query execution
--dooms transaction if XACT_ABORT is on, @@trancount will be 0
--can rethrow original error
--severity level is always 16
--state 1 <= 255




--raiserror

--throw

print 1;
raiserror ('test %s %d', 3, 1, 'hello', 55) with nowait, log
print 2;


print 1;

select * from sys.messages where message_id > 13000

raiserror (13001, 16, 1)
print 2;



--does not stop query execution
--severity must be 10 <= 19
--severity <=9 only prints msg 50000
--severity >= 20 terminates the connection
--state must be 1 <= 255
--does not doom transaction if XACT_ABORT is on
--error number must be > 13000 and in sys.messages
--with log: write to app and error log
--with nowait: send to client immediately


