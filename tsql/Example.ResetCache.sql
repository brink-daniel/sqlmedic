/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Nov 2016</Date>
	<Title>Clear cache for testing</Title>
	<Description>Remove all pages from the database buffer pool cache to test query IO performance.</Description>
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


--NEVER DO THIS ON PRODUCTION!!!!
checkpoint
go 
dbcc dropcleanbuffers
go
--NEVER DO THIS ON PRODUCTION!!!!
