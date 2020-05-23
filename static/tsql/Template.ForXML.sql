/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>For XML and OPENXML</Title>
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





--XML is case sensitive!!


--create xml
select top 2
	[database].name,
	[database].database_id,
	[database].create_date,
	[database].compatibility_level

from sys.databases as [database]
order by [database].name
for xml auto, elements, root('databases'), xmlschema

--raw: single element rows, fragments, attribute centric, no root
--auto: document
--path: 

--elements: turn attributes into elements

--root: make/set document header

--xmlschema: include xsd

--NB:
-- must set ORDER BY clause else xml document will be broken
-- column must be arrange one-many


--read xml as table
declare @xml nvarchar(1000) = '
<databases>  
  <database database_id="6">
    <name>CentralAccounts</name>   
    <create_date>2017-09-11T10:00:54.930</create_date>
    <compatibility_level>130</compatibility_level>
  </database>
   <database database_id="24">
    <name>ASPState</name>
    <create_date>2017-10-24T12:30:46.080</create_date>
    <compatibility_level>130</compatibility_level>
  </database>
</databases>
';

declare @handle int
exec sys.sp_xml_preparedocument 
	@handle output,
	@xml;

select
	*
from openxml(@handle, '/databases/database', 11)
with (
	name varchar(250),
	database_id int,
	create_date datetime,
	compatibility_level int
);

exec sys.sp_xml_removedocument @handle

--flags:
-- 0|1: attribute-centric
-- 2: element-centric
-- 8: mix?
-- 11: mix




--query xml

declare @x xml
set @x =  cast(@xml as xml)

select
 @x.query ('
	for $i in /databases/database
	let $d := $i/name
	where $i/@database_id < 66
	order by ($d)[1]
	return
	<database>
		<name>{data($i/name)}</name>
	</database>
') as [database]



/*
	@x.value()
	@x.exist(),
	@x.modify(),
	@x.nodes()
*/

