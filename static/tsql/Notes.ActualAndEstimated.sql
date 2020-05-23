/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2017</Date>
	<Title>Compare estimated and actual query plans</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Notes</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/






--estimated. does not execute query
set showplan_xml on --estimated sql plan
set showplan_text on --hierarchical view of estimated query plan
set showplan_all on --text + all columns

--extended event: query_pre_execution_showplan
--trace event: Showplan XML or Showplan XML for Query Compile




--actual. executes query
set statistics xml on --actual execution plan
set statistics io on
set statistics time on
set statistics profile on --same as showplan all, but executes the query give actual vs estimated

--extended event: query_post_execution_showplan
--trace event: Showplan XML Statistics Profile
--query store


--Note: Query plan is not available via SQL Trace in SQL Database (Azure)