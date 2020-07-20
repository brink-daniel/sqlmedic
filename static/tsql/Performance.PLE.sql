
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>20 Jul 2020</Date>
	<Title>Get Page Life Expectancy (PLE)</Title>
	<Description>Page Life Expectancy (PLE) is the average time, in seconds, that pages stay in the buffer pool before they are flushed out by queries needing different data. The more data kept in memory, the better query performance will be as it avoids the time cost of having to access physical storage. The PLE figure changes constantly, monitor it frequently over a long period to create a performance baseline. 
	<br />Microsoft recommends a minimum PLE of 300 seconds, but this number is outdated. The recommendation does not factor in NUMA nodes and was set years ago when 16GB of memory was considered large. Today, the average production server will have multiple NUMA nodes and at least 256GB of memory. A more realistic minimum PLE would ((Memory in GB * Number of NUMA nodes) / 8) * 300. For example, for a server with 256GB of memory and two NUMA nodes, a PLE of ((256*2)/8) * 300 = 19200 would be a much better starting point, giving each NUMA node a good chance that at least an 8th of the data it requires will be cached.
	<br />PLE, and thus query performance, can be improved by adding more memory, but the real fix is to enhance indexes and code quality - fix those large scans caused by missing indexes or code that is not SARGable.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

select 
    cntr_value as [PLE (seconds)]
from sys.dm_os_performance_counters
where
    counter_name = 'Page life expectancy'
    and object_name = 'SQLServer:Buffer Manager'

