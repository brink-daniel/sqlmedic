
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>28 Oct 2020</Date>
	<Title>Singleton Pattern in SQL</Title>
	<Description>How to use sp_getapplock and sp_releaseapplock to implement a singleton pattern in SQL. This is very useful to prevent multiple queries from accessing the same resource at the same time, e.g. prevent jobs from overlapping.</Description>
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


--https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-getapplock-transact-sql?view=sql-server-ver15


--demo steps:
-- 1. create procedures task1 and task2
-- 2. open two new query windows
-- 3. execute task1 in the first query window
--     and execute task2 in the second query window at the same time
-- 4. note how the second task will wait for the first task to finish before it starts
-- 5. and voila, you have singleton access to resource "abc"


create procedure task1
as
begin
	
	--get or wait for an exclusive lock on resource "abc"
	--you can call the resource anything you like. 
	--for this example I called the resource "abc"
	--while this runs, no other process will be able to get a lock on "abc", 
	--thus creating a simple singleton pattern in SQL
	--over any process, irrespective of the tables accessed
	exec sp_getapplock @resource='abc', @lockmode='exclusive', @lockowner='session'

	--your code here
	waitfor delay '00:00:15' --15 seconds


	--release lock
	exec sp_releaseapplock @resource='abc', @lockowner='session'


end
go



create procedure task2
as
begin
	
	exec sp_getapplock @resource='abc', @lockmode='exclusive', @lockowner='session'

	--your code here
	waitfor delay '00:00:15' --15 seconds

	--release lock
	exec sp_releaseapplock @resource='abc', @lockowner='session'


end