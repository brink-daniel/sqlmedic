/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>View Job History</Title>
	<Description>Use the sp_help_jobhistory stored procedure to quickly view job history information.</Description>
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



--view latest job history
exec msdb..sp_help_jobhistory
       @job_name = '_GBO_Batch_Intraday_Every_10Mins_07:30_to_02:30',
       @start_run_date = 20160223, --YYYYMMDD 23 Feb 2016, CHANGE DATE HERE
       @start_run_time = 130000, --HHMMSS 1pm, CHANGE TIME HERE
       @mode = 'Full'

--view history for a specific step
exec msdb..sp_help_jobhistory
       @job_name = '_GBO_Batch_Intraday_Every_10Mins_07:30_to_02:30',
       @start_run_date = 20160223, --YYYYMMDD 23 Feb 2016, CHANGE DATE HERE
       @start_run_time = 130000, --HHMMSS 1pm, CHANGE TIME HERE
       @mode = 'Full',
       @step_id = 2 --CentralTransactionalStore..spMergeHoldings
