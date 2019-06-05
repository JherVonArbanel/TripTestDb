SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE Procedure [dbo].[usp_CheckResponsesExistsForAirRequest]
(@airRequestKey  int)
AS 

select count(*) From AirResponse resp INNER JOIN AirSubRequest subRequest 
on resp.airSubRequestKey = subRequest.airSubRequestKey
INNER JOIN 
AirRequest request ON subRequest.airRequestKey = request.airRequestKey 
where request.airRequestKey = @airRequestKey
GO
