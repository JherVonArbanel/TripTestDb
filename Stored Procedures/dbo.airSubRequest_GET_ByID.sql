SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[airSubRequest_GET_ByID]
(
	@airRequestKey	INT,
	@legIndex		INT
)
AS
BEGIN

	SELECT TOP 1 
		airSubRequestKey,
		airRequestDepartureAirport,
		airRequestArrivalAirport,
		airRequestDepartureDate,
		airRequestArrivalDate,
		airSpecificDepartTime,
		isnull(groupKey , 0 ) as groupKey
	FROM AirSubRequest WITH(NOLOCK)
	WHERE airRequestKey = @airRequestKey AND 
		airSubRequestLegIndex = @legIndex AND ISNULL(groupKey,1) = 1

END
GO
