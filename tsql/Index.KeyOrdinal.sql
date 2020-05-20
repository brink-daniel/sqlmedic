/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>15 Nov 2016</Date>
	<Title>Key Ordinal</Title>
	<Description>It is recommended to order index keys (excluding first) from most to least selective</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>minute</Frequency>
	<Category>Performance</Category>
	<Foreachdb>true</Foreachdb>
	<store></store>
	<Window>00:00 - 23:59</Window>
	<Days>M0WTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set nocount on

create table #stats (
	[table] varchar(250),
	stat varchar(250),
	[column] varchar(250),
	[distinct] bigint null
)

create table #histogram (
	RANGE_HI_KEY nvarchar(max),
	RANGE_ROWS int,
	EQ_ROWS int,
	DISTINCT_RANGE_ROWS int,
	AVG_RANGE_ROWS int
)

insert into #stats ([table], stat, [column])
select
	t.name as [table],
	s.name as [stat],
	c.name as [column]

from
	sys.stats as s

	inner join sys.stats_columns as sc
	on s.object_id = sc.object_id
		and s.stats_id = sc.stats_id
		and sc.stats_column_id = 1 --first key

	inner join sys.columns as c
	on sc.object_id = c.object_id
		and sc.column_id = c.column_id

	inner join sys.tables as t
	on c.object_id = t.object_id



declare
	@table varchar(250),
	@column varchar(250),      
	@sql nvarchar(max)

while exists (select top 1 'X' as x from #stats where [distinct] is null)
begin
	select top 1
		@table = [table],
		@column = [column],
		@sql = 'dbcc show_statistics (' + [table] + ', ' + stat + ') with no_infomsgs, histogram'
	from #stats
	where [distinct] is null

	truncate table #histogram

	insert into #histogram (RANGE_HI_KEY,RANGE_ROWS,EQ_ROWS,DISTINCT_RANGE_ROWS,AVG_RANGE_ROWS)
	exec (@sql)

	update #stats
	set
		[distinct] =  isnull((select count(*) + sum(DISTINCT_RANGE_ROWS) from #histogram), 0)
	where
		[table] = @table
		and [column] = @column
end

select
	db_name() as [database],
	a.[table],
	a.[index],
	a.[key],
	a.key_ordinal,
	a.proposed_key_ordinal

from 
	(
		select
			t.name as [table],   
			i.name as [index],
			c.name as [key],
			ic.key_ordinal,      
			row_number() over (partition by t.name, i.name order by d.[distinct] desc) + 1 as proposed_key_ordinal

		from 
			sys.indexes as i

			inner join sys.tables as t
			on i.object_id = t.object_id

			inner join sys.index_columns as ic
			on i.object_id = ic.object_id
				and i.index_id = ic.index_id
				and ic.is_included_column = 0     
				and ic.key_ordinal > 1     

			inner join (
				select
					object_id,
					index_id
				from sys.index_columns
				where is_included_column = 0      
				group by
					object_id,
					index_id
				having max(key_ordinal) > 2
			) as l 
			on i.object_id = l.object_id
				and i.index_id = l.index_id

			inner join sys.columns as c
			on i.object_id = c.object_id
				and ic.column_id = c.column_id

			left join (
				select distinct 
					[table],
					[column],
					[distinct]
				from #stats   
			) as d
			on t.name = d.[table]
				and c.name = d.[column]

		where i.[type_desc] = 'NONCLUSTERED'

	) as a

where a.key_ordinal != a.proposed_key_ordinal   


drop table    
	#stats, 
	#histogram

