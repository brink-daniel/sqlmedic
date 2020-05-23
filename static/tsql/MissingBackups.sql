/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>18 Nov 2013</Date>
	<Title>Missing backups</Title>
	<Description>A full database backup is deemed to outdated if it is older than 24 hours or the average hours between previous full database backups. Similarly transaction log backups are deemed to be outdated when they are older than 3 hours or the average hours between previous transaction log backups. Databases set to use the Full Recovery model should have regular full and transaction log backups, while databases using the Simple Recovery model only needs regular full databases backups.</Description>
	<Pass>No missing or outdated full or log backups detected.</Pass>	
	<Fail>{x} missing or outdated full or log backup(s) detected.</Fail>
	<Check>true</Check>
	<Advanced>false</Advanced>
	<Frequency>daily</Frequency>
	<Category>Backups</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/

set transaction isolation level read uncommitted


declare
	@maxAgeFullBackup int,
	@maxAgeLogBackup int,
	@nullDate datetime


select
	@maxAgeFullBackup = 24,
	@maxAgeLogBackup = 3,
	@nullDate = '01-01-1990'
	
	

select 
	d.name as DatabaseName,
	d.recovery_model_desc as [Recovery],
	case t.[Type]
		when 'D' then 'Full'
		when 'L' then 'Log'
	end as [Type],
	max(isnull(b.backup_start_date, @nullDate)) as LastBackup,
	datediff(hour, max(isnull(b.backup_start_date, @nullDate)), getdate()) as Age,
	datediff(hour, min(isnull(b.backup_start_date, @nullDate)), max(isnull(b.backup_start_date, @nullDate))) / nullif((count(b.backup_start_date) - 1), 0) as [AverageAge]
	
into #tmp 

from 
	(
		select 'D' as [Type]
		union select 'L' as [Type]
	
	) as t
	
	cross join sys.databases as d
	
	left join msdb..backupset as b
	on t.[Type] = b.[Type]
		and d.name = b.database_name
	

where
	d.state_desc = 'ONLINE'
	and d.name <> 'tempdb'
	and not (
		d.recovery_model_desc = 'SIMPLE' 
		and t.[Type] = 'L'
	)	
	
	
group by 
	d.Name,
	d.recovery_model_desc,
	t.[Type]
	
having
	datediff(hour, max(isnull(b.backup_start_date, @nullDate)), getdate()) is null
	or (
		datediff(hour, max(isnull(b.backup_start_date, @nullDate)), getdate()) > 
			isnull((datediff(hour, min(isnull(b.backup_start_date, @nullDate)), max(isnull(b.backup_start_date, @nullDate))) / nullif( (count(b.backup_start_date) - 1), 0)),
				case t.[Type] 
					when 'D' then @maxAgeFullBackup
					when 'L' then @maxAgeLogBackup
				end	
			)
		and datediff(hour, max(isnull(b.backup_start_date, @nullDate)), getdate()) > case t.[Type] 
																		when 'D' then @maxAgeFullBackup
																		when 'L' then @maxAgeLogBackup
																	end																		
	)
	or datediff(hour, max(isnull(b.backup_start_date, @nullDate)), getdate()) > 168 --1 week!
	
	
order by
	d.Name,
	t.[Type]
	


--fuzzy logic
update #tmp
set
	AverageAge = 24
where 
	AverageAge > 6 
	and AverageAge < 24
	
update #tmp
set
	AverageAge = 168
where 
	AverageAge > 24
	and AverageAge < 168


select 
	DatabaseName as [Database],
	[Recovery] as [Recovery model],
	[Type] as [Backup type],
	LastBackup as [Last backup],
	Age as [Age (in hours)],
	[AverageAge] as [Average age (in hours)]
	
from #tmp
where Age > AverageAge 

drop table #tmp
