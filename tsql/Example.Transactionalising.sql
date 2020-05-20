/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>06 Nov 2016</Date>
	<Title>Transactionalise stored procedures</Title>
	<Description>Create and handle transactions and save points.</Description>
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

create procedure SampleProc

	--optional: parameters here
	@ParentTradeId int

as
begin  


	declare 
		--check for open transactions created by .net or the calling procedure/code
		@tranCountStart int = @@trancount,
		--create a unique name for your transaction/save point
		@currentTran varchar(250) = 'Trade' + convert(varchar(250),@intParentTradeId) + 'spSampleProc'


	if @tranCountStart > 0
	begin
		--a transaction has already been created, so we only need to mark a save point
		save tran @currentTran
	end
	else
	begin
		--no transaction exists
		--start a new transaction
		begin tran
	end

	--execute all your code inside a try..catch
	begin try


		----------------------------------------------------------
		/*
		YOUR CODE HERE

		exec SubProc @ParentTradeId=1

		while exists (select top 1 'x' as s from Users where Clue = 0)
		begin
			exec DeleteUser
		end

		*/
		----------------------------------------------------------


		--this line will only be reached if all your code above was successful
		--only if you created the transaction should you call commit
		--else the calling code will fail when it later tries to exec more code or commit or rollback             
		if @tranCountStart = 0
		begin
			commit tran
		end

	end try       
	begin catch          
		--something went wrong

		if @tranCountStart > 0
		begin
			--only rollback to your start/save point
			--this allows the calling procedure/code still to run more procs
			--and do its own commit/rollback
			rollback tran @currentTran
		end
		else
		begin
			--only if you created the tran should you do a full rollback of the tran
			rollback tran 
		end

		--pass the error up to the calling code
		declare @e varchar(250) = error_message()
		raiserror('SampleProc: %s', 16, 1, @e) 

	end catch

end
