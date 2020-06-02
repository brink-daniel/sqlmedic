/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Jun 2020</Date>
	<Title>Loop through all tables in all databases</Title>
	<Description>Simple query to loop through all tables in all databases without having to write a WHILE loop or CURSOR.</Description>
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

exec sp_msforeachdb @command1='

	use ? 

	exec sp_msforeachtable @command1=''			

		print ''''?.!''''

	'', @replacechar = ''!'';

';