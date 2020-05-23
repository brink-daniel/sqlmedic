/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Paging</Title>
	<Description>How to do paging using the OFFSET and FETCH NEXT clauses</Description>
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



create procedure spGetDataPaged

@StartDate datetime,
@EndDate datetime,

--paging
@PageNum int = 1,
@PageSize int = 10

as

begin

       if @intPageNum < 1
       begin
              set @intPageNum = 1
       end



       select
              t.Currency,
              sum(Movement) as Movement
       from 
              [TableT] as t
              
       where
              t.EntryDate >= @dteStartDate
              and t.EntryDate <= @dteEndDate

       group by
              t.Currency

       order by 
              t.Currency

              offset ((@intPageNum -1) * @intPageSize) rows --from where to start returning rows

              fetch next (@intPageSize) rows only --how many rows to return
       

end
