/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jul 2017</Date>
	<Title>Refresh views</Title>
	<Description>Refresh all views in all databases.</Description>
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




declare
	@view varchar(250),
	@schema varchar(250),
	@database varchar(250),
	@sql2 nvarchar(max)


create table #views (
	[Database] varchar(250),
	[View] varchar(250),
	[Schema] varchar(250)
)



exec sp_msforeachdb '
use [?]
print ''?''

insert into #views ([Database], [View], [Schema])
select
	db_name() as [Database],
	v.name as [View],
	s.name as [Schema]
from 
	sys.views as v with (nolock)

	inner join sys.schemas as s with (nolock)
	on v.schema_id = s.schema_id

where v.is_ms_shipped = 0
'


while exists (select top 1 * from #views)
begin
    select top 1
        @view = [View],
        @database = [Database],
		@schema = [Schema]
    from #views

    delete top (1) from #views
    where
        [View] = @view
        and [Database] = @database


    set @sql2 = '
        use [' + @database + ']

		print ''' + @database + '.' + @schema + '.' + @view + ''' 

        exec sp_refreshview ''' + @schema + '.' + @view + ''''

    exec sp_executesql @sql2	
end

drop table #views