/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>09 Jul 2017</Date>
	<Title>Rebuild index</Title>
	<Description>Rebuild all indexes in all databases.</Description>
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




USE [master]


exec sp_msforeachdb '

use [?]
print ''?''

if ''?'' != ''tempdb''
begin
	exec sp_msforeachtable @command1=''
	print ''''#''''
	alter index all on # rebuild

	'', @replacechar=''#''
end

'



