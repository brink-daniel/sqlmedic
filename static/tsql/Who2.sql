/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Jan 2014</Date>
	<Title>Current activity</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/




--new version
select *
from sys.dm_exec_sessions as es cross apply sys.dm_exec_input_buffer(es.session_id, null) as ib


--old version

set transaction isolation level read uncommitted



create table #who2
(
	[SPID] smallint,
	[Status] nvarchar(30),
	[Blocked by] smallint,
	[Event info] varchar(max),
	[Command text] varchar(max),
	[Login] nvarchar(128),
	[Host name] nvarchar(128),
	[Database] nvarchar(128),
	[Program] nvarchar(128),
	[Total elapsed time (seconds)] decimal(26,2),
	[CPU time (seconds)] decimal(26,2),
	[Reads] bigint,
	[Writes] bigint,
	[Logical reads] bigint
)



insert into #who2
	([SPID],[Status],[Blocked by],[Event info],
	[Command text],[Login],[Host name],[Database],[Program],
	[Total elapsed time (seconds)],[CPU time (seconds)],
	[Reads],[Writes],[Logical reads])
select
	r.session_id as [SPID],
	r.[status] as [Status],
	r.blocking_session_id as [Blocked by],
	convert(varchar(max), '') as [Event info],
	t.[text] as [Command text],
	s.login_name as [Login],
	s.[host_name] as [Host name],
	db_name(r.database_id) as [Database],
	s.[program_name] as [Program],
	convert(decimal(26,2), r.total_elapsed_time / 1000.0) as [Total elapsed time (seconds)],
	convert(decimal(26,2), r.cpu_time / 1000.0) as [CPU time (seconds)],
	r.reads as [Reads],
	r.writes as [Writes],
	r.logical_reads as [Logical reads]


from
	sys.dm_exec_requests as r

	inner join sys.dm_exec_sessions as s
	on s.session_id = r.session_id
		and s.is_user_process = 1
	
	cross apply sys.dm_exec_sql_text(r.[sql_handle]) as t

where r.session_id <> @@spid


create table #info
(
	[EventType] varchar(max),
	[Parameters] varchar(max),
	[EventInfo] varchar(max)
)


declare 	
	@spid int,
	@sql nvarchar(max),
	@EventInfo varchar(max)


create table #spid
(
	spid int
)

insert into #spid
	(spid)
select distinct
	spid
from #who2



while exists (select *
from #spid)
begin
	delete from #info


	select top 1
		@spid = spid,
		@EventInfo = null
	from #spid

	delete from #spid where spid = @spid

	select @sql = N'DBCC INPUTBUFFER(' + convert(nvarchar,@spid) + ')'

	begin try
		insert into #info
		([EventType], [Parameters],[EventInfo])
	exec sp_executesql @statement=@sql with recompile
	end try
	begin catch
	
	end catch



	update #who2
	set		
		[Event info] = (select top 1
		[EventInfo]
	from #info)
	where SPID = @spid


end


select
	[SPID],
	[Status],
	[Blocked by],
	substring(ltrim([Event info]), 1, 100) as [Event info],
	substring(ltrim([Command text]), 1, 100) as [Command text],
	[Login],
	[Host name],
	[Database],
	[Program],
	[Total elapsed time (seconds)],
	[CPU time (seconds)],
	[Reads],
	[Writes],
	[Logical reads]

from #who2
order by
	[CPU time (seconds)] desc

drop table #who2
drop table #info
drop table #spid	