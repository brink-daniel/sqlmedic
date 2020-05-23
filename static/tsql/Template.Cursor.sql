
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Cursor</Title>
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




declare @db sysname;

declare db cursor for
	select
		name
	from sys.databases;

open db;

fetch next from db into @db;

while @@fetch_status = 0 --not end of table
begin

	print @db

	fetch next from db into @db;

end

close db;

deallocate db; 
