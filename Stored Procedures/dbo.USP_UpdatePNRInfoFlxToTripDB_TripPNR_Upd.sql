SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdatePNRInfoFlxToTripDB_TripPNR_Upd]
(  
	@TripKey INT
)
AS  
  
BEGIN  

	UPDATE [TripPNRRemarks] SET Active = 0 WHERE tripKey = @tripKey
 
END  

GO
