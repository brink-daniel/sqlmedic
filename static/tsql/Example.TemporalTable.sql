/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Nov 2016</Date>
	<Title>Temporal Table</Title>
	<Description>Convert existing table to Temporal Table</Description>
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



--requirements for system versioned table
-- primary key constraint
-- two UTC datetime2 columns, period expressed as open-close, start is inclusive, end is exclusive
-- start column marked with "generate always as row start"
-- end column marked with "generate always as row ends"
-- period for system_time (start column, end column)
-- table option system_versioning on
-- linked history table





--the database must have compatibility_level = 130 mode (SQL 2016)
--select * from sys.databases where name = db_name()
use MyDatabaseNameHere
go



--disable any old trigger based audit solutions you my have
/*
drop trigger tr_MyTableNameHere_Delete
drop trigger tr_MyTableNameHere_Insert
drop trigger tr_MyTableNameHere_Update
*/
go


--create new schema to store history table with exact same name as source table
create schema History  
go

--add hidden columns to source table to track changes
alter table MyTableNameHere   
add
       sysStartTime datetime2 generated always as row start hidden default getutcdate(), 
       sysEndTime datetime2 generated always as row end hidden default convert(datetime2, '9999-12-31 23:59:59.9999999'),   
       period for system_time (sysStartTime, sysEndTime)
go

--enable temporal
alter table MyTableNameHere  
set (system_versioning = on (history_table = History.MyTableNameHere))   
go


--done
 


--now you can also query the table AS AT a specific time
--NB: We didn�t import the old audit data, you will have to migrate your audit data

declare @businessDate datetime2 = '03 June 2016'

select top 100 * 
from MyTableNameHere for system_time as of @businessDate --how the data looked as on @businessDate
--where Column1 = 1


--other query options

select top 100 * 
from MyTableNameHere for system_time from @start to @end --exclusive of delimiters


select top 100 * 
from MyTableNameHere for system_time between @start to @end --exclusive of start delimiter, inclusive of end delimiter


select top 100 * 
from MyTableNameHere for system_time contained in (@start, @end) --inclusive of delimiters

 