SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdatePNRInfoFlxToTripDB_Trip_Upd]
(  
	@TripKey INT
)
AS  
  
BEGIN  

	Update  [Trip] set tripStatusKey = 2 Where tripStatusKey = 1 and tripKey = @tripKey
 
END  

GO
