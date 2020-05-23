
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>For JSON and OPENJSON</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Template</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



--auto
select top 2
	name as [Database],
	collation_name as [Collation.Name]
from sys.databases as [Databases]
for json auto, root('Databases'), include_null_values--, without_array_wrapper


--path: set sub element
select top 2
	name as [Database.Name],
	collation_name as [Database.Collation.Name]
from sys.databases as [Database]
for json path, root('Databases'), include_null_values--, without_array_wrapper




declare @json nvarchar(max) = '

{"Databases":[{"Database":{"Name":"master","Collation":{"Name":"SQL_Latin1_General_CP1_CI_AS"}}},{"Database":{"Name":"tempdb","Collation":{"Name":"SQL_Latin1_General_CP1_CI_AS"}}}]}

'

select isjson(@json)


select
	*
from openjson(@json) --return default columns (key, value, type)

select
	*
from openjson(@json, 'lax $.Databases') --use strict to raise error if property does not exist
with (
	[Name] varchar(250) '$.Database.Name',
	[Collation] varchar(250) '$.Database.Collation.Name'
)


declare @json2 nvarchar(max) = N'
	{
		"Database":{
			"Name" : "master",
			"Collation" : {
				"Name" : "SQL_Latin1_General_CP1_CI_AS"
			}
		}
	}

'

select 
	isjson(@json2),
	json_value(@json2, '$.Database.Name'), --get scalar
	json_query(@json2, '$.Database.Collation') --get object


set @json2 = json_modify(@json2, '$.Database.Name', 'Hello') --do the same for delete (use null value) and insert (new attribute)

select json_value(@json2, '$.Database.Name')