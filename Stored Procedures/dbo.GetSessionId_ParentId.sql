SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[GetSessionId_ParentId]   
(  
 @travelRequestKey INT, @legIndex int  
)  
AS                
BEGIN   
 DECLARE @thirdPartySessionId NVARCHAR(200)  
 SELECT @thirdPartySessionId = ThirdPartySessionId FROM AirSubRequest where airRequestKey = (select airRequestKey FROM TripRequest_air where  
 tripRequestKey = @travelRequestKey)  and airSubRequestLegIndex=@legIndex
 SELECT @thirdPartySessionId as thirdPartySessionId  
END 
 
GO
