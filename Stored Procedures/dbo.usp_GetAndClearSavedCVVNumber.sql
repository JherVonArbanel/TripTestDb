SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[usp_GetAndClearSavedCVVNumber](@tripKey int, @creditCardKey int)
as
begin
Declare @encryptedKey nvarchar(max)
Declare @encryptedvarBinaryKey varbinary(max)
Declare @CreditCarNumberDecrypted nvarchar(200)

select top 1 @encryptedKey=  PTACode from trip..TripPassengerCreditCardInfo Where TripKey=@tripKey and CreditCardKey=@creditCardKey and UsedforHotel=1

EXEC vault..usp_GetDecryptedByKey @encryptedKey,@CreditCarNumberDecrypted output

select @CreditCarNumberDecrypted

update trip..TripPassengerCreditCardInfo set  PTACode=''  Where TripKey=@tripKey and CreditCardKey=@creditCardKey

end

-- exec usp_GetAndClearSavedCVVNumber 43041, 8238
GO
