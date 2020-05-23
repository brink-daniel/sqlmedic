/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Sep 2017</Date>
	<Title>Last restore date</Title>
	<Description>Get the date on which a database was last restored from backups.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>false</Advanced>
	<Frequency>manual</Frequency>
	<Category>Backups</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


select
	a.name,
	a.restore_date
	
from 
	(
		select
			*,
			row_number() over (partition by d.Name order by r.restore_date desc) as RowNumber
						
		from 
			sys.databases as d
	
			left join msdb..restorehistory as r
			on d.Name = r.destination_database_name
	) as a

where a.RowNumber = 1


