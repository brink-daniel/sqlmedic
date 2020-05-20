
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>RedGate SQL Monitor - Most expensive queries</Title>
	<Description>RedGate Software has a really good product called SQL Monitor. Here is how to query the products database directly for the top most expensive queries. This script is compatible with RedGate SQL Monitor version 5.2.3.3831</Description>
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


set transaction isolation level read uncommitted


declare
	@intMinDate bigint,
	@intMaxDate bigint


select
	--return top queries in last 15 minutes
	@intMinDate = utils.DateTimeToTicks(dateadd(minute, -15, getutcdate())),
	@intMaxDate = utils.DateTimeToTicks(getutcdate())
	


create table #data (
	[Database] varchar(250),
	[Object] varchar(250),	
	ExecutionCount bigint,
	ExecutionTime bigint,
	LogicalReads bigint,
	LogicalWrites bigint,
	PhysicalReads bigint,
	WorkerTime bigint,	
	ExecutionCountRank int,
	ExecutionTimeRank int,
	LogicalReadsRank int,
	LogicalWritesRank int,
	PhysicalReadsRank int,
	WorkerTimeRank int
)

insert into #data ([Database],[Object],ExecutionCount,ExecutionTime,LogicalReads,LogicalWrites,
	PhysicalReads,WorkerTime,ExecutionCountRank,ExecutionTimeRank,LogicalReadsRank,LogicalWritesRank,
	PhysicalReadsRank,WorkerTimeRank)
select	
	f.[Database],
	isnull(object_name(p.objectid, p.dbid), p.text) as [Object],
	
	f.ExecutionCount,
	f.ExecutionTime,
	f.LogicalReads,
	f.LogicalWrites,
	f.PhysicalReads,
	f.WorkerTime,
	
	f.ExecutionCountRank,
	f.ExecutionTimeRank,
	f.LogicalReadsRank,
	f.LogicalWritesRank,
	f.PhysicalReadsRank,
	f.WorkerTimeRank

from
	(	
	
		select 
			*
		from
			(
				select
					d.[Database],			
					d.SqlHandle,							
					
					d.ExecutionCount,
					d.ExecutionTime,
					d.LogicalReads,
					d.LogicalWrites,
					d.PhysicalReads,
					d.WorkerTime,					
					
					row_number() over(order by d.ExecutionCount desc) as ExecutionCountRank,
					row_number() over(order by d.ExecutionTime desc) as ExecutionTimeRank,
					row_number() over(order by d.LogicalReads desc) as LogicalReadsRank,
					row_number() over(order by d.LogicalWrites desc) as LogicalWritesRank,
					row_number() over(order by d.PhysicalReads desc) as PhysicalReadsRank,
					row_number() over(order by d.WorkerTime desc) as WorkerTimeRank		
				
				from 
					(		
						select					
							k._DatabaseName as [Database],
							k._SqlHandle as [SqlHandle],
													
							lv.ExecutionCount - isnull(sv.ExecutionCount,0) as ExecutionCount,
							lv.ExecutionTime - isnull(sv.ExecutionTime,0) as ExecutionTime,
							lv.LogicalReads - isnull(sv.LogicalReads,0) as LogicalReads,
							lv.LogicalWrites - isnull(sv.LogicalWrites,0) as LogicalWrites,
							lv.PhysicalReads - isnull(sv.PhysicalReads,0) as PhysicalReads,
							lv.WorkerTime - isnull(sv.WorkerTime,0) as WorkerTime

						from  
							(
								select distinct 
									Id
								from data.Cluster_SqlServer_TopQueries_Sightings as s with (index (Cluster_SqlServer_TopQueries_Sightings_SightingDate_Id))
								where 
									s.SightingDate >= @intMinDate 
									and s.SightingDate <= @intMaxDate
							) as s

							inner loop join data.Cluster_SqlServer_TopQueries_Keys as k
							on k.Id = s.Id									
							
							outer apply (
								--get the last performance data recorded before the specified query date range
								select top 1 
									CollectionDate,
									us._ExecutionCount as ExecutionCount,
									us._ExecutionTime as ExecutionTime,
									us._LogicalReads as LogicalReads,
									us._LogicalWrites as LogicalWrites,
									us._PhysicalReads as PhysicalReads,
									us._WorkerTime as WorkerTime

								from data.Cluster_SqlServer_TopQueries_UnstableSamples as us
								where 
									us.Id = k.Id
									and us.CollectionDate <= @intMinDate
								
								order by 
									us.CollectionDate desc
							) as sv
							
							cross apply (
								--get the latest performance data recorded
								select top 1 
									CollectionDate,
									us._ExecutionCount as ExecutionCount,
									us._ExecutionTime as ExecutionTime,
									us._LogicalReads as LogicalReads,
									us._LogicalWrites as LogicalWrites,
									us._PhysicalReads as PhysicalReads,
									us._WorkerTime as WorkerTime

								from data.Cluster_SqlServer_TopQueries_UnstableSamples as us
								where 
									us.Id = k.Id
									and us.CollectionDate > @intMinDate
									and us.CollectionDate <= @intMaxDate
								
								order by 
									us.CollectionDate desc
							) as lv
					) as d
				
				where 
					d.ExecutionCount > 0
					or d.ExecutionTime > 0
					or d.LogicalReads > 0
					or d.LogicalWrites > 0
					or d.PhysicalReads > 0
					or d.WorkerTime > 0
			) as s 
			
		where
			ExecutionCountRank <= 10
			or ExecutionTimeRank <= 10
			or LogicalReadsRank <= 10
			or LogicalWritesRank <= 10
			or PhysicalReadsRank <= 10
			or WorkerTimeRank <= 10
	
	) as f	
	
	cross apply sys.dm_exec_sql_text(isnull(convert(varbinary(64), f.SqlHandle, 1), 0x)) as p

	

--top queries by execution count
select
	[Database],
	[Object],
	ExecutionCount,
	ExecutionTime,
	WorkerTime,
	PhysicalReads,
	LogicalReads,
	LogicalWrites	

from #data

where
	ExecutionCountRank <= 10

order by
	ExecutionCountRank
	
	

--top queries by execution time
select
	[Database],
	[Object],
	ExecutionCount,
	ExecutionTime,
	WorkerTime,
	PhysicalReads,
	LogicalReads,
	LogicalWrites

from #data

where
	ExecutionTimeRank <= 10

order by
	ExecutionTimeRank
	
	
--top queries by worker time
select
	[Database],
	[Object],
	ExecutionCount,
	ExecutionTime,
	WorkerTime,
	PhysicalReads,
	LogicalReads,
	LogicalWrites

from #data

where
	WorkerTimeRank <= 10

order by
	WorkerTimeRank
	
	
	
--top queries by logical reads
select
	[Database],
	[Object],
	ExecutionCount,
	ExecutionTime,
	WorkerTime,
	PhysicalReads,
	LogicalReads,
	LogicalWrites

from #data

where
	LogicalReadsRank <= 10

order by
	LogicalReadsRank
	
	


--top queries by logical writes
select
	[Database],
	[Object],
	ExecutionCount,
	ExecutionTime,
	WorkerTime,
	PhysicalReads,
	LogicalReads,
	LogicalWrites

from #data

where
	LogicalWritesRank <= 10

order by
	LogicalWritesRank
	

--top queries by physical reads
select
	[Database],
	[Object],
	ExecutionCount,
	ExecutionTime,
	WorkerTime,
	PhysicalReads,
	LogicalReads,
	LogicalWrites

from #data

where
	PhysicalReadsRank <= 10

order by
	PhysicalReadsRank	
	

	
drop table #data
	

