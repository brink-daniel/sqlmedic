/* 
<Script> 
    <Author>Daniel Brink</Author> 
    <Date>08 Dec 2014</Date> 
    <Title>Outdated metadata on views</Title> 
    <Description>Persistent metadata for a view can become outdated because of changes to the underlying objects upon which the view depends.</Description> 
    <Pass>No views found with outdated metadata.</Pass>     
    <Fail>{x} views found with outdated metadata.</Fail> 
    <Check>true</Check> 
    <Advanced>false</Advanced> 
    <Frequency>weekly</Frequency> 
    <Category>Stability</Category> 
    <Foreachdb>true</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script> 
*/ 

set transaction isolation level read uncommitted

create table #views ( 
    [Database] varchar(250), 
    [View] varchar(250), 
    [View_Modify_Date] datetime, 
    [Referenced_Database] varchar(250), 
    [Referenced_Object] varchar(250), 
    [Referenced_Object_Modify_Date] datetime 
) 



insert into #views ([Database],[View],[View_Modify_Date],[Referenced_Database], 
    [Referenced_Object],[Referenced_Object_Modify_Date]) 
select 
    db_name() as [Database], 
    v.name as [View], 
    v.modify_date as [View_Modify_Date], 
    isnull(d.referenced_database_name, db_name()) as [Referenced_Database], 
    d.referenced_entity_name as [Referenced_Object], 
    o.modify_date as [Referenced_Object_Modify_Date] 
         
from 
    sys.views as v 

    inner join sys.sql_expression_dependencies as d 
    on v.[object_id] = d.referencing_id 
         
    left join sys.objects as o 
    on d.referenced_id = o.[object_id] 


delete from #views 
where 
    [Referenced_Object_Modify_Date] is null 
    and [Referenced_Object] is null 

	
declare 
	@sql nvarchar(4000),
	@object varchar(250),
	@database varchar(250)




while exists (select top 1 'X' as x from #views where [Referenced_Object_Modify_Date] is null) 
begin 

    select top 1
		@object = [Referenced_Object],
		@database = [Referenced_Database],
		@sql = N'          
			if exists ( 
				select * from sys.databases 
				where name =  @database) 
			begin 
				if exists ( 
					select * from [' + [Referenced_Database] + '].sys.objects 
					where name = @object) 
				begin 
					update #views 
					set 
						[Referenced_Object_Modify_Date] = (select modify_date from [' + [Referenced_Database] + '].sys.objects where name = @object) 
					where 
						[Referenced_Database] = @database
						and [Referenced_Object] = @object 
				end
			end 
           
			if @@rowcount <= 0
			begin
				update #views 
				set 
					[Referenced_Object_Modify_Date] = getdate() --flag this object
				from #views 
				where   
					[Referenced_Database] = @database
					and [Referenced_Object] = @object
			end
		' 
         
    from #views 
    where [Referenced_Object_Modify_Date] is null 
     
     
    exec sp_executesql @sql, N'@object varchar(250), @database varchar(250)',
		@object = @object,
		@database = @database
		with recompile
		

end 


select distinct 
    [Database], 
    [View], 
    'exec [' + [Database] + ']..sp_refreshview @viewname = ''' + [View] + '''' as Script
     
from #views 
where [Referenced_Object_Modify_Date] > [View_Modify_Date] 


drop table  #views 