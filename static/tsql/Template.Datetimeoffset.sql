
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>Datetimeoffset and AT TIME ZONE</Title>
	<Description></Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Template</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/



select * from sys.time_zone_info
where current_utc_offset = '+11:00'



declare 
	@sys datetimeoffset = sysdatetimeoffset(),
	@sys2 datetime = getutcdate()

select 
	@sys as [System],	
	@sys2  as [UTC],
	switchoffset(@sys, '+11:00') as Sydney,
	switchoffset(@sys, '+02:00') as CapeTown,
	todatetimeoffset(@sys2, '+00:00') as UTC_Offset,   --just adds offset, does not adjust time
	todatetimeoffset(@sys2, '+11:00') as UTC_Offset2,   --just adds offset, does not adjust time
	@sys2 at time zone 'UTC' at time zone 'AUS Eastern Standard Time', --first add correct time zone offset
	@sys at time zone 'Pacific Standard Time' at time zone 'AUS Eastern Standard Time'

