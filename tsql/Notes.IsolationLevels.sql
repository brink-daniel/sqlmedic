/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2017</Date>
	<Title>Isolation levels</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Notes</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/




set transaction isolation level read committed

--options:

-- read uncommitted
--- allow reading of uncommitted data, dirty reads, ignores locks. does not issue shared locks when reading
--- warning: page splits can cause your query to miss a row, can be blocked by schema modification locks


-- read committed
--- default, pessimistic, cannot read uncommitted changes, issues shared locks when reading to prevent changes, releases row and page locks after reading, 
--- warning: if key change happens while doing an index scan it can result in a row appearing twice in your result set!

-- repeatable read
--- same as read committed, but holds all shared locks on all existing data that was read until end of query
--- warning: if another tran inserts a row, it will result in a phantom read when rerunning the query, reduces concurrency, deadlocks more frequent.

-- serialisable
--- most pessimistic level, uses range locks to prevent inserts
--- warning: reduces concurrency, slow performance due to lock contention

-- snapshot
--- optimistic, allows read & write of same data without blocking, preserves state as at the start of the transaction, must first be allowed in db configuration, all data changes stored in tempdb, increases concurrency by eliminating the need for read locks as a copy of the data is used for the duration of the query.
--- warning: possible row versioning cause tempdb growth and cpu pressure, does not work with distributed transactions and cannot be used on system databases, updates and long running reads are slow, all databases accesses, including tempdb, must have snapshot enabled. Update conflicts causes rollback; same data modified by two different transactions. fails if any meta data changes, e.g. index rebuilds.

-- read committed snapshot 
--- optimistic alternate to read committed, must first be allowed in db configuration, preserves state as at the start of the read, works with distributed transactions, long running query - data consistent to point in time as at start of query.
--- warning: high resource overhead to maintain row snapshots, write require exclusive locks and will block other transactions