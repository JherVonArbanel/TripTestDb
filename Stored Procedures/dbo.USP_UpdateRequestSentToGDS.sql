SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[USP_UpdateRequestSentToGDS] 
(
@airrequestID int , 
@nooFRequests int 
) 

AS 

Update TripRequest_air SET  NoOFRequestSentToGDS = @nooFRequests where airRequestKey = @airrequestID
GO
