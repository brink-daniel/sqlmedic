
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2017</Date>
	<Title>Memory-optimized table and stored procedures</Title>
	<Description>Useful for high data ingestion rate, high volume high performance data reads, complex business logic in stored procedures, real-time data access, session state management and applications that uses a lot of temporary tables, table variables and table valued parameters.</Description>
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


USE [master]
GO

create database Test
go

--create file group

ALTER DATABASE [Test] ADD FILEGROUP [MemDat1] CONTAINS MEMORY_OPTIMIZED_DATA 
GO

--add file
ALTER DATABASE [Test] ADD FILE ( NAME = N'MemFile1', FILENAME = N'D:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\MemFile1' ) TO FILEGROUP [MemDat1]


use Test
go

--create memory optimized table
create table UserSession (
	ID int identity(1,1) constraint PK_ID primary key nonclustered hash with (bucket_count = 1000), -- 2x expected unique values & must have PK if durable
	TS datetime constraint DF_TS_Now default(getdate()),
	Val1 varchar(50) not null index Ix_val1 nonclustered, 
	Val2 varchar(50),
	index ix_val2 clustered columnstore  --NB cannot add column store at column level, NB: cannot alter table with column store index
) with (memory_optimized = on, durability = schema_and_data) --durability = schema_only  --no logging overhead
-- maximum of 8 non-clustered indexes on table, all are covering, exists in memory only and does not contain data
-- index updates are not logged
-- allowed indexes; non-clustered, columnstore and hash
-- indexes must be defined in the table create statement, else have to ALTER table to add/alter/drop indexes


--non-clustered HASH - point lookups
--Non-clustered b-tree - ordered data, < , >, !=
--clustered Columnstore - large range scans


--drop index
alter table UserSession drop index ix_val2


--add index
alter table UserSession add index Ix_qty2 (Qty) 

--add column and index
alter table UserSession add Qty int index Ix_qty (Qty) 

--change bucket count
alter table UserSession alter index PK_ID rebuild with (bucket_count = 2000)



--optimize durable data
alter database Test set delayed_durability = forced

--or

begin tran
commit tran with (delayed_durability = on)

--or

begin atomic with (delayed_durability = on, ...
end



go

go

insert into UserSession (Val1)
values ('hello')

select * from UserSession
go

drop procedure GetUserSessions
go

create or alter procedure GetUserSessions --cannot alter tsql sp into native compiled
with native_compilation, schemabinding
as
begin atomic with (transaction isolation level = snapshot, language = N'English', DELAYED_DURABILITY = on) --SNAPSHOT, REPEATABLEREAD, and SERIALIZABLE.

	--rules
	-- select * not allowed
	-- must have ATOMIC block
	-- no tempdb, create non-durable mem tables
	-- no cursors, use WHILE loops
	-- no CASE statement
	-- no MERGE statement
	-- no SELECT INTO
	-- no UPDATE with FROM
	-- no TOP with PERCENT or WITH TIES
	-- no DISTINCT with AGGREGATES
	-- no INTERSECT, EXCEPT, APPLY, PIVOT, UNPIVOT, LIKE or CONTAINS
	-- no CTE
	-- no Multi-row inserts
	-- no exec with recompile
	-- no VIEW


	select Val1 from dbo.UserSession --two part names needed for schemabinding
	where TS > dateadd(day,-1, getdate());

end;
go


exec GetUserSessions

go


--to optimize performance, stats are not collected by default
select * from sys.dm_exec_procedure_stats
select * from sys.dm_exec_query_stats



--enable stats on native compiled procs and queries
exec sys.sp_xtp_control_proc_exec_stats @new_collection_value = 1
exec sys.sp_xtp_control_query_exec_stats @new_collection_value = 1 -- @database_id, #xtp_object_id







