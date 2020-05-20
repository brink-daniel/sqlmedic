/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Broken Objects</Title>
	<Description>Find objects that do not compile</Description>
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



set nocount on

create table #objects (
       [database] varchar(250),
       [object] varchar(250)
)



exec sp_msforeachdb '
       use [?]

       insert into #objects ([database], [object])
       select 
              db_name() as [database],
              o.name as [object]
       from sys.objects as o
       where
              o.is_ms_shipped = 0
              and o.[type] in (''P'', ''V'', ''TR'', ''FN'', ''TF'')
              and db_name() not in (''tempdb'', ''ReportServer'', ''master'', ''msdb'', ''model'', ''ReportServerTempDB'')

'


create table #broken (
       [database] varchar(250),
       [object] varchar(250),
       [script] varchar(8000),
       [error] varchar(8000)
)


while exists (select top 1 'X' as x from #objects)
begin
       declare
              @database varchar(250) = null,
              @object varchar(250) = null,
              @sql nvarchar(3000) = null

       select
              @database = [database],
              @object = [object],
              @sql = 'exec ' + [database] + '..sp_refreshsqlmodule ''' + [object] + ''''
       from #objects


       delete from #objects
       where
              [database] = @database
              and [object] = @object


       begin try
              print @sql
              exec (@sql)
       end try
       begin catch
              insert into #broken ([database], [object], [script], [error])
              values (@database, @object, @sql, error_message())
       end catch

end



select * from #broken
order by
       [database], 
       [object]
       



drop table #objects, #broken
