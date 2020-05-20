/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>21 Oct 2017</Date>
	<Title>Merge with Output</Title>
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




merge into TargetTable with (serializable) as t 
using SourceData as s
	on t.ID = s.ID
when matched and t.Column1 <> s.Column1 then
	update 
	set
		t.Column1 = s.Column1
when matched and t.Column1 = s.Column1 then
	delete
when not matched by target and s.Column1 = 5 then --source exists, but not target
	insert values (s.Column1)
when not matched by source and t.Column1 = 8 then --target exists, but not source
	delete
when not matched by source and t.Column1 = 9 then --target exists, but not source
	update
	set
		t.Column1 = 7
output --return to caller
	$action as Action, --"INSERT", "UPDATE" or "DELETE"
	inserted.Column1 as Inserted,
	deleted.Column1 as Deleted
output --log to table
	$action as Action,
	inserted.Column1 as Inserted,
	deleted.Column1 as Deleted
	into AuditTable (Action, Inserted, Deleted)  --AuditTable cannot have FK or Triggers
;