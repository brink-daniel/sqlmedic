/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>24 Apr 2015</Date>
	<Title>Duplicate indexes</Title>
	<Description>Adding non-clustered indexes can greatly speed up queries by reducing the IO, CPU and memory usage, but having duplicate (or very similar) indexes can actually hurt performance as SQL has to maintain these and cache different indexes depending on the query. This script identifies POSSIBLE duplicate indexes which could possibly be merged or dropped. Always look at the usage statistics before removing any index.</Description>
	<Pass>No duplicate indexes found.</Pass>	
	<Fail>{x} possible duplicate indexes found.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Index</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


;with #index as (
	select
		t.name as [table],
		i.name as [index],
		c.name as [column],
		i.type_desc as [type],
		ic.key_ordinal,
		i.is_primary_key

	from
		sys.indexes as i

		inner join sys.tables as t
		on i.object_id = t.object_id

		inner join sys.index_columns as ic
		on i.object_id = ic.object_id
			and i.index_id = ic.index_id		

		inner join sys.columns as c
		on i.object_id = c.object_id
			and ic.column_id = c.column_id

),
#data as (
	select distinct 
		i.[table],
		i.[index]
	from #index as i
	where 
		type = 'NONCLUSTERED'
		and i.is_primary_key = 0
),
#firstKeyMatch as (
	--first key column must match	
	select
		a.[table],
		a.[index],
		i3.[index] as match

	from
		#data as a
		
		inner join #index as i2
		on a.[table] = i2.[table]
			and a.[index] = i2.[index]
			and i2.key_ordinal = 1

		inner join #index as i3
		on i2.[table] = i3.[table]
			and i2.[index] != i3.[index]
			and i3.key_ordinal = 1
			and i2.[column] = i3.[column]

),
#sameKeyColumns as (
	--must have same key columns
	select 
		m.[table],
		m.[index],
		m.match	

	from 
		#firstKeyMatch as m

		inner join #index as i1
		on m.[table] = i1.[table]
			and m.[index] = i1.[index]
			and i1.key_ordinal > 0 -- key column

		left join #index as i2
		on i1.[table] = i2.[table]
			and m.match = i2.[index]
			and i2.key_ordinal > 0 -- key column
			and i1.[column] = i2.[column]


	group by
		m.[table],
		m.[index],
		m.match

	having count(i1.[column]) <= sum(case when i2.[column] is not null then 1 else 0 end)
)

--must cover all same columns
select 
	db_name() as [database],
	m.[table],
	m.[index] as [Index],
	m.match	as [Matches index]

from 
	#sameKeyColumns as m

	inner join #index as i1
	on m.[table] = i1.[table]
		and m.[index] = i1.[index]		

	left join #index as i2
	on i1.[table] = i2.[table]
		and m.match = i2.[index]		
		and i1.[column] = i2.[column]

group by
	m.[table],
	m.[index],
	m.match

having count(i1.[column]) <= sum(case when i2.[column] is not null then 1 else 0 end)
