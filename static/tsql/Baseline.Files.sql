/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2015</Date>
	<Title>Files</Title>
	<Description>Database file status</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Baseline</Category>
	<Foreachdb>false</Foreachdb>
	<store>Baseline_File</store>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


select 
	getdate() as [TimeStamp],
	@@servername as [Server],
	database_id,
	file_id,
	file_guid,
	type,
	type_desc,
	data_space_id,
	name,
	physical_name,
	state,
	state_desc,
	size,
	max_size,
	growth,
	is_media_read_only,
	is_read_only,
	is_sparse,
	is_percent_growth,
	is_name_reserved,
	credential_id

from sys.master_files 