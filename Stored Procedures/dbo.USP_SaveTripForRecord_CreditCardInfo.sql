SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripPassengerCreditCardInfo table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_CreditCardInfo]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @TripTypeComponent As int,
	 @CreditCardKey As int,
	 @creditCardVendorCode As nchar(4) ,
	 @creditCardDescription As nvarchar(50),
	 @creditCardLastFourDigit As int ,
	 @expiryMonth As int ,
	 @expiryYear As int ,
	 @creditCardTypeKey As int 
	 
AS
BEGIN
 
INSERT INTO TripPassengerCreditCardInfo
			(TripKey, PassengerKey, TripTypeComponent, CreditCardKey, creditCardVendorCode 
			,creditCardDescription, creditCardLastFourDigit,expiryMonth,expiryYear,creditCardTypeKey)
        VALUES 
			(@TripKey ,@PassengerKey ,@TripTypeComponent ,@CreditCardKey,@creditCardVendorCode
			,@creditCardDescription,@creditCardLastFourDigit,@expiryMonth,@expiryYear,@creditCardTypeKey)
END

GO
