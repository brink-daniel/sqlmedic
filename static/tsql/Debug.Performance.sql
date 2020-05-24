/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>24 May 2020</Date>
	<Title>Print current line</Title>
	<Description>When debugging code, it is often useful to print out the current time and line number at random points during the execution of the query. The is especially useful when optimizing very large complex stored procedure as it allows you to quickly and easily identify the slow queries without having to search through pages of Statistic IO and Time output.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Debug</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


begin try;throw 50000,'',1;end try begin catch;print convert(varchar(50), getdate(), 113) + '[' + cast(error_line() as varchar) + ']';end catch
