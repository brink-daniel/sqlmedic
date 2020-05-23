


/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>18 Dec 2017</Date>
	<Title>Database integrity check</Title>
	<Description>Fast integrity check skipping user indexes and using exclusive database and table locks instead of snapshot where possible</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Integrity</Category>
	<Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



use master
--Do not run on a live production system as exclusive locks may cause problems
exec sp_msforeachdb '

	print ''?''

	if ''?'' in (''master'', ''tempdb'', ''msdb'')
	begin
		dbcc checkdb (?, noindex) with no_infomsgs
	end
	else
	begin
		dbcc checkdb (?, noindex) with no_infomsgs, tablock -----warning exclusive locks taken to speed up the process!!!
	end

'