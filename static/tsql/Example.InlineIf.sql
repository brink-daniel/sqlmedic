/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>12 Nov 2020</Date>
	<Title>Inline IF statement</Title>
	<Description>Simple demo of inline IIF statement. The same can be done with an inline CASE statement, but the inline IIF syntax is more succinct.</Description>
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


declare @a int = 1, @b int = 2;

select iif(@a = @b, 'true', 'false');