/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Missing Objects</Title>
	<Description>Find objects that reference other objects that no longer exists</Description>
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



create table #dependencyTree (
       referencing_database_name varchar(250),
       referencing_object varchar(250),
       referencing_id int,
       referenced_database_name varchar(250),
       referenced_entity_name varchar(250),
       referenced_id int
)

--build dependency tree
exec sp_msforeachdb '
       use [?]

       insert into #dependencyTree (referencing_database_name,referencing_object,
              referencing_id,referenced_database_name,referenced_entity_name,
              referenced_id)
       select 
              db_name() as referencing_database_name,
              object_name(referencing_id) as referencing_object, 
              referencing_id,
              isnull(referenced_database_name, db_name()) as referenced_database_name,
              referenced_entity_name,
              isnull(referenced_id, isnull(object_id(referenced_entity_name), object_id(referenced_database_name + ''..'' + referenced_entity_name))) as referenced_id
       from 
              sys.sql_expression_dependencies as d

              inner join sys.objects as o
              on d.referencing_id = o.object_id
                     and o.is_ms_shipped = 0

       where
              db_name() not in (''tempdb'', ''ReportServer'', ''master'', ''msdb'', ''model'', ''ReportServerTempDB'')
              and isnull(referenced_id, isnull(object_id(referenced_entity_name), object_id(referenced_database_name + ''..'' + referenced_entity_name))) is null
              and len(referenced_entity_name) > 5 --filter out object aliases, an alias is meant to be a SHORTCUT for a table name, to make it quicker to type, some people don''t get this :( 
              

'


select 
       * 
from #dependencyTree 


order by
       referencing_database_name,
       referencing_object



drop table #dependencyTree
