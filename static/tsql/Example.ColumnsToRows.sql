
/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>02 Jun 2020</Date>
	<Title>Merge multiple rows into a single column</Title>
	<Description>Simple query to concatenate multiple rows into a single column.</Description>
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

with #data as (
    select
        *
    from (
        values
            ('Ford', 'Focus'),
            ('Ford', 'Fiesta'),
            ('Ford', 'Ranger'),
            ('Ford', 'Mondeo'),
            ('Toyota', 'Camry'),
            ('Toyota', 'Corolla')

    ) as x (Make, Model)
)
select distinct
    d.Make
    ,substring((
        select ',' + d1.Model as [text()]
        from #data as d1
        where d1.Make = d.Make
        order by d1.Make, d1.Model
        for xml PATH('')
    ), 2, 1000) pat_euid

from #data as d