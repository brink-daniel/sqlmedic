/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Indexed view</Title>
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







--notes:



--Indexed view:
-- "with (noexpand)" force use of view in Std ed.
-- recalcualted for every modification
-- Enterprise ed. will use the view to optimize queries even if view not queried directly
-- Must have "with schemabinding", count_big(*) when doing aggregates
-- first index must be clustered


--rules:
-- cannot use select *
-- cannot use union, except or intersect
-- no subqueries
-- no outer joins or recursive back on the same table 
-- no TOP
-- no DISTINCT
-- SUM() may only reference 1 column
-- no aggregate on nallable
-- no CTE
-- no other views
-- no derived tables
-- no non-deterministic functions
-- no data outside the database
-- no count(*)
-- must include count_big(*) when using an aggregate function
-- must use with schemabinding
-- first index must a be unique clustered index
-- functions used on view must be always deterministic, else you cannot create a clustered index on the view


--partitioned view 
-- must select all columns
-- no implicit conversions
-- one column in same ordinal positions and have check constraints
-- UNION ALL + PK
-- Partitioning column (PK) cannot be a computed, identity, default, or timestamp column
-- only one partitioning constraint


--update-able view rules:
-- cannot insert or update on derived column names (no sum/max/min,functions)
-- "with check option" insert or update still visible to the user, cannot delete rows not visible
-- only insert/update/delete one table at a time
-- must use two part names
-- no group by, having or distinct
-- no "top" + "with check option"
-- partitioned views are update-able


-- cannot delete from a view that contains multiple tables, because no way to specific which table to delete from (no columns as in the update and insert)ers 
-- use "instead of" triggers to make any view editable


/*

deterministic
------------------
guaranteed to return same output across all calls given the same inputs
computed column and indexed view requires function to be deterministic
function must have "with schemabinding" in header to be deterministic

coalesce()
isnull()
abs()
sqrt()

rand(seed)


non-deterministic
--------------------
not guaranteed to return same output across all calls given the same inputs
executed only once in entire query, thus same results for all rows, wrap it in a function, it will get executed once per row and have different results

sysdatetime()
rand() -- no seed, returns float between 0 and 1
newid()

cast() & convert() --string to date and time, because login language settings

exception: newid()
*/
