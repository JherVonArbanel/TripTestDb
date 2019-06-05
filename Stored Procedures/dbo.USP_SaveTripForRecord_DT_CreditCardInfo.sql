SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripPassengerCreditCardInfo table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_CreditCardInfo]
	 @TripKey As int ,
	 @PassengerKey As int ,
	 @TripTypeComponent As int,
	 @CreditCardKey As int
	 
AS
BEGIN
 
INSERT INTO TripPassengerCreditCardInfo
			(TripKey, PassengerKey, TripTypeComponent, CreditCardKey)
        VALUES 
			(@TripKey ,@PassengerKey ,@TripTypeComponent ,@CreditCardKey)
END

GO
