/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>26 Nov 2013</Date>
	<Title>Number of tempdb data files</Title>
	<Description>It is recommended to have one tempdb data file per visible cpu core. This allows for the maximum concurrent processes in the tempdb and reduces IO wait times.</Description>
	<Pass>No configuration problems were detected.</Pass>	
	<Fail>The tempdb data files are not configured for optimal performance.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>weekly</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted

select
	(select count(*) from tempdb.sys.database_files where type_desc = 'ROWS') as [tempdb data file count],
	(select cpu_count from sys.dm_os_sys_info) as [CPU count]
where
	(select count(*) from tempdb.sys.database_files where type_desc = 'ROWS') <> (select cpu_count from sys.dm_os_sys_info)

