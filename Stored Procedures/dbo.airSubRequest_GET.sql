SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[airSubRequest_GET]
(
	@airRequestKey INT
)
AS
BEGIN

	SELECT airSubRequestKey,
		airRequestDepartureAirport,
		airRequestArrivalAirport,
		airRequestDepartureDate,
		airRequestArrivalDate ,
		airSubRequestLegIndex ,
		airspecificDepartTime ,
		ISNULL(groupKey,0) AS groupKey 
	FROM AirSubRequest 
	WHERE airRequestKey = @airRequestKey	 AND ISNULL(groupKey,0) = 1 
	Order by airSubRequestKey 
END

GO
