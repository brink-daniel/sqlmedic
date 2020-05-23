/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>05 Jun 2016</Date>
	<Title>List files in directory</Title>
	<Description>Using xp_dirtree allows you to list files in a folder without using xp_cmdshell. xp_dirtree has three parameters; directory, depth & type.</Description>
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


exec master.dbo.xp_dirtree 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup', 1 /*current folder only*/, 1 /*files only*/