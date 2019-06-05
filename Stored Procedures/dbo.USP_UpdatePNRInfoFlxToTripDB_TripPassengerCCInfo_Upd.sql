SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdatePNRInfoFlxToTripDB_TripPassengerCCInfo_Upd]
(  
	@TripKey INT
)
AS  
  
BEGIN  

	Update TripPassengerCreditCardInfo set Active = 0 where TripKey = @TripKey
 
END  

GO
