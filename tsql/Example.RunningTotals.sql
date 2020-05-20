/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>19 Jun 2016</Date>
	<Title>Running totals</Title>
	<Description>How to calculate running totals using the OVER() aggregate function</Description>
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



select
       Ledger,
       Account,
       Currency,
       [Date],
       Movement,  
       sum(Movement) over (
              partition by               
                     Ledger,
                     Account,
                     Currency        
              order by                   
                     Ledger,
                     Account,
                     Currency,
                     [Date]
              rows unbounded preceding
       ) as RunningTotal

from Journals

where DataType = 2 
       
order by
       Ledger,
       Account,
       Currency,
       [Date]
