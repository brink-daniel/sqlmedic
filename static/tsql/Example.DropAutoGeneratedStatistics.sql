/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Drop auto generated statistics</Title>
	<Description>Drop all auto-generated column statistics.</Description>
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


create table #tmp (
       Script varchar(8000)
)

exec sp_msforeachdb '
       use [?]

       insert into #tmp (Script)
       select 
              ''use [?] drop statistics dbo.'' + o.name +''.'' + s.name as Script
       from 
              sys.stats as s

              inner join sys.objects as o
              on s.[object_id] = o.[object_id]
                     and o.is_ms_shipped = 0

       where 
              s.auto_created = 1
              and db_name() not in (''msdb'', ''master'', ''tempdb'', ''model'', ''ReportServer'', ''ReportServerTempDB'', ''RedGateMonitor'')
'

select * from #tmp
order by
       Script

drop table #tmp
