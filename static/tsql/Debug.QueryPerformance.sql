/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>28 Aug 2020</Date>
	<Title>Solve query performance issues</Title>
	<Description>Checklist to help identify the cause of slow query performance.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


/*

Why is my query running slow?

- Table or index scans
- Non-SARGable join or filter predicates preventing the use of indexes
- Key-lookups
- Data type or collation conversion
- Parameter sniffing
- While loops or cursors
- Large amounts of data in tempdb
- Large amounts of data in table variables
- Views joined on views
- Unnecessary tables or columns queried
- Incorrect or unnecessary join, query & table hints
- Incorrect estimates on row numbers
- Cross joins on large tables
- Use of order by, distinct or union
- Correlated sub queries or functions
- Merge statements containing joins
- Too many join permutations for the query optimizer to process
- Duplicate indexes slowing down inserts, updates and deletes
- Joins on table valued functions
- Doing row lookups against a column store index, instead of range selects
- MAXDOP settings
- Cardinality Estimation (CE) / Compatibility level
- Missing SQL patches
- ARITHABORT
- Insufficient memory
- Slow reads and writes to physical storage
- SQL Always-On Availability Group synchronising over slow network or to under-spec'ed secondary
- SQL not using all CPU cores
- Misaligned NUMA nodes in virtual machine
- Incorrectly configured network cards
- Resource governor limiting CPU, I/O or memory
- Blocking queries
- Joins across linked servers
- Other query activty in SQL, activity in the OS or local services, e.g. SSAS, SSIS or SSRS 

*/