/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>29 Oct 2017</Date>
	<Title>XACT_ABORT</Title>
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



set xact_abort on
-- immediately terminates execution. no statement after error is executed
-- immediately dooms any open transactions

create table Table1 (
	Val int not null
)


begin tran

insert into Table1 (Val)
values (1)

insert into Table1 (Val)
values (null)

insert into Table1 (Val)
values (3)


select @@trancount

commit tran


select @@trancount

select * from Table1

drop table Table1