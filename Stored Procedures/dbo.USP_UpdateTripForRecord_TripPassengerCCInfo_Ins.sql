SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripForRecord_TripPassengerCCInfo_Ins]
(  
	@TripKey INT,
	@PassengerKey INT,
	@TripTypeComponent INT,
	@CreditCardKey INT
)AS  
  
BEGIN  

	INSERT INTO TripPassengerCreditCardInfo(TripKey, PassengerKey, TripTypeComponent, CreditCardKey) 
	VALUES (@TripKey, @PassengerKey, @TripTypeComponent, @CreditCardKey) 
   
END  

GO
