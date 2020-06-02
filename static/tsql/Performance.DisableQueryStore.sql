/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Jun 2020</Date>
	<Title>Disable Query Store on all databases</Title>
	<Description>The Query Store is useful for debugging performance issues, but should be disabled when not needed or used.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Performance</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

exec sp_msforeachdb '      

	alter database [?] set query_store = off

'