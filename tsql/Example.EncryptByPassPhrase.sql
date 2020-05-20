/*
<Script>
	<Author>Daniel Brink</Author>
	<Date>13 May 2017</Date>
	<Title>Encrypt varchar or single column</Title>
	<Description>Encrypt and decrypt data with a pass phrase. This is very useful if you only need to encrypt selected columns.</Description>
	<Pass></Pass>	
	<Fail></Fail>
	<Check>false</Check>
	<Advanced>true</Advanced>
	<Frequency>manual</Frequency>
	<Category>Example</Category>
	<Foreachdb>false</Foreachdb>
	<Window>00:00 - 23:59</Window>
	<Days>MTWTFSS</Days>
	<Alert>normal</Alert>
</Script>
*/


set transaction isolation level read uncommitted


declare @encrypted varbinary(8000) 

set @encrypted = EncryptByPassPhrase('password123', 'Top secret ninja hush hush data to be encrypted')


select 
	@encrypted as [Encrypted],
	convert(varchar(250), DecryptByPassPhrase('password123', @encrypted)) as [Decrypted],
	convert(varchar(250), DecryptByPassPhrase('wrong pass', @encrypted)) as [Decrypted_Fail],
	convert(varchar(100),DecryptByPassPhrase('password123', 
		0x01000000DFC6B30BB7C7D000D3E09A9AEFC9701E1B0C4B4DF2FED4F5D702E07D73202EBB4C52802BB404B4114C1E38C7A80508AE95FDDEE5533B88F418273F1BCA26A478))
		as [Decrypted_EncryptedByAnotherServer]
