
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>22 Jul 2020</Date>
	<Title>Calculate Average Transaction Delay</Title>
	<Description>When using Always On in Synchronous-commit mode, transactions wait to send the transaction confirmation to the client until the secondary replica has hardened the log to disk. This script uses performance counters to measure the Avg Transaction Delay caused by having to wait for the transaction to be hardened to the synchronous secondary.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Always-On</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


--https://docs.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-database-replica?view=sql-server-ver15

with #delay as (
	select
		instance_name
		,cntr_value
	from sys.dm_os_performance_counters
	where
		counter_name = 'Transaction Delay' 
		--Delay in waiting for unterminated commit acknowledgment for all the current transactions, 
		--in milliseconds. Divide by Mirrored Write Transaction/sec to get Avg Transaction Delay
		and object_name = 'SQLServer:Database Replica'
),
#writes as (
	select
		instance_name
		,cntr_value
	from sys.dm_os_performance_counters
	where
		counter_name = 'Mirrored Write Transactions/sec' 
		--Number of transactions that were written to the primary database and then waited to 
		--commit until the log was sent to the secondary database, in the last second.
		and object_name = 'SQLServer:Database Replica'
)
select
	d.instance_name as [Database]
	,d.cntr_value as [Transaction Delay (milliseconds)]
	,w.cntr_value as [Mirrored Write Transactions/sec]
	,(d.cntr_value * 1.0) / (nullif(w.cntr_value, 0) * 1.0) as [Avg Transaction Delay (milliseconds)]
from
	#delay as d

	inner join #writes as w
	on d.instance_name = w.instance_name

order by d.instance_name;