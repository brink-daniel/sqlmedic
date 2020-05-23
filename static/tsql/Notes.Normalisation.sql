/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>11 Dec 2017</Date>
	<Title>Normalisation</Title>
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



/*
Normalisation
- First Normal Form (1NF): PK + Once value per column + No duplicate (Phone1, Phone2, etc) column groups
- Second Normal Form (2NF): 1NF + All columns must be a fact of the whole PK 
- Third Normal Form (3NF): 2NF + No dependency between columns
- Boyce-Codd Normal From (BCNF): 3NF + No composite keys

*/