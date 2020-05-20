/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>22 Nov 2013</Date>
	<Title>Server configuration</Title>
	<Description>Some non-default running (applied) configuration options such as allowing xp_cmdshell could be a security risk and should be reviewed.</Description>
	<Pass>No configuration problems were detected.</Pass>	
	<Fail>This instance is configured with non default options.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Configuration</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	c.name as [Configuration option],
	c.value_in_use as [Value in use],
	d.default_value as [Default value]
 
from 
	sys.configurations as c

	inner join (

		select 'access check cache bucket count' as name, 0 as default_value
		union select 'access check cache quota' as name, 0 as default_value		
		union select 'Ad Hoc Distributed Queries' as name, 0 as default_value
		union select 'affinity I/O mask' as name, 0 as default_value
		union select 'affinity mask' as name, 0 as default_value		
		union select 'affinity64 I/O mask' as name, 0 as default_value
		union select 'affinity64 mask' as name, 0 as default_value		
		--union select 'Agent XPs' as name, 0 as default_value
		union select 'allow updates' as name, 0 as default_value
		union select 'awe enabled' as name, 0 as default_value
		union select 'blocked process threshold' as name, 0 as default_value
		union select 'c2 audit mode' as name, 0 as default_value
		union select 'clr enabled' as name, 0 as default_value		
		union select 'common criteria compliance enabled' as name, 0 as default_value		
		union select 'cost threshold for parallelism' as name, 5 as default_value
		union select 'cross db ownership chaining' as name,0 as default_value
		union select 'cursor threshold' as name, -1 as default_value
		union select 'Database Mail XPs' as name, 0 as default_value
		union select 'default full-text language' as name, 1033 as default_value
		union select 'default language' as name, 0 as default_value
		union select 'default trace enabled' as name, 1 as default_value
		union select 'disallow results from triggers' as name, 0 as default_value
		union select 'EKM provider enabled' as name, 0 as default_value
		union select 'filestream access level' as name, 0 as default_value
		union select 'fill factor (%)' as name, 0 as default_value
		union select 'ft crawl bandwidth (max)' as name, 100 as default_value
		union select 'ft crawl bandwidth (min)' as name, 0 as default_value
		union select 'ft notify bandwidth (max)' as name, 100 as default_value
		union select 'ft notify bandwidth (min)' as name, 0 as default_value
		union select 'index create memory (KB)' as name, 0 as default_value
		union select 'in-doubt xact resolution' as name, 0 as default_value
		union select 'lightweight pooling' as name, 0 as default_value
		union select 'locks' as name, 0 as default_value
		union select 'max degree of parallelism' as name, 0 as default_value
		union select 'max full-text crawl range' as name, 4 as default_value
		union select 'max server memory (MB)' as name, 2147483647 as default_value
		union select 'max text repl size (B)' as name, 65536 as default_value
		union select 'max worker threads' as name, 0 as default_value
		union select 'media retention' as name, 0 as default_value
		union select 'min memory per query (KB)' as name, 1024 as default_value
		--union select 'min server memory (MB)' as name, 0 as default_value
		union select 'nested triggers' as name, 1 as default_value
		union select 'network packet size (B)' as name, 4096 as default_value
		union select 'Ole Automation Procedures' as name, 0 as default_value
		union select 'open objects' as name, 0 as default_value
		union select 'optimize for ad hoc workloads' as name, 0 as default_value
		union select 'PH timeout (s)' as name, 60 as default_value
		union select 'precompute rank' as name, 0 as default_value
		union select 'priority boost' as name, 0 as default_value
		union select 'query governor cost limit' as name, 0 as default_value
		union select 'query wait (s)' as name, -1 as default_value
		union select 'recovery interval (min)' as name, 0 as default_value
		union select 'remote access' as name, 1 as default_value
		union select 'remote admin connections' as name, 0 as default_value
		union select 'remote login timeout (s)' as name, 20 as default_value
		union select 'remote proc trans' as name, 0 as default_value
		union select 'remote query timeout (s)' as name, 600 as default_value
		union select 'Replication XPs' as name, 0 as default_value
		union select 'RPC parameter data validation' as name, 0 as default_value
		union select 'scan for startup procs' as name, 0 as default_value
		union select 'server trigger recursion' as name, 1 as default_value
		union select 'set working set size' as name, 0 as default_value
		union select 'show advanced options' as name, 0 as default_value
		union select 'SMO and DMO XPs' as name, 1 as default_value
		union select 'SQL Mail XPs' as name, 0 as default_value
		union select 'transform noise words' as name, 0 as default_value
		union select 'two digit year cutoff' as name, 2049 as default_value
		union select 'user connections' as name, 0 as default_value
		union select 'user options' as name, 0 as default_value
		union select 'Web Assistant Procedures' as name, 0 as default_value
		union select 'xp_cmdshell' as name, 0 as default_value		
	
	) as d 
	on c.name = d.name
		and c.value_in_use <> d.default_value
