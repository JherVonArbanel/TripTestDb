SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetAirSubRequestKey_Travelfusion] 
(
	@airRequestKey INT
)
AS              
BEGIN 
	SELECT airSubRequestKey FROM trip..AirSubRequest 
	WHERE airRequestKey = @airRequestKey 
	and groupKey = 7 AND airSubRequestLegIndex <> -1
	ORDER BY airSubRequestLegIndex
END
GO
