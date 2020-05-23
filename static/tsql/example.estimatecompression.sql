/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>05 Oct 2017</Date>
	<Title>Estimate database size if all indexes were compressed</Title>
	<Description>Use the sp_estimate_data_compression_savings stored procedure to estimate the size of your database if PAGE compression was enabled on all rowstore indexes.</Description>
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




create table #tables (
	schemaName varchar(250),
	tableName varchar(250)
)

insert into #tables (schemaName,tableName)
select 
	s.name,
	t.name
from 
	sys.tables as t

	inner join sys.schemas as s
	on t.schema_id = s.schema_id


create table #estimates (
	[object_name] varchar(250),
	[schema_name] varchar(250),
	[index_id] int,
	[partition_number] int,
	[size_with_current_compression_setting(KB)] bigint,
	[size_with_requested_compression_setting(KB)] bigint,
	[sample_size_with_current_compression_setting(KB)] bigint,
	[sample_size_with_requested_compression_setting(KB)] bigint
)



declare
	@schemaName varchar(250),
	@tableName varchar(250)

while exists (select * from #tables)
begin
	select top 1
		@schemaName = schemaName,
		@tableName = tableName

	from #tables

	insert into #estimates
	exec sp_estimate_data_compression_savings 
		@schema_name = @schemaName,
		@object_name = @tableName,
		@index_id = null,
		@partition_number = null,
		@data_compression = 'PAGE'
	

	delete from #tables 
	where 
		schemaName = @schemaName
		and tableName = @tableName

end

select 
	db_name() as [Database],
	count(*) as [Indexes],
	sum([size_with_current_compression_setting(KB)]) as [size_with_current_compression_setting(KB)],
	sum([size_with_requested_compression_setting(KB)]) as [size_with_requested_compression_setting(KB)],
	sum([sample_size_with_current_compression_setting(KB)]) as [sample_size_with_current_compression_setting(KB)],
	sum([sample_size_with_requested_compression_setting(KB)]) as [sample_size_with_requested_compression_setting(KB)]

from #estimates

drop table #tables, #estimates