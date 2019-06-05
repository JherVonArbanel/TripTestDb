SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[airSubRequest_GET_ByID_20180202]
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
	FROM AirSubRequest 
	WHERE airRequestKey = @airRequestKey AND 
		airSubRequestLegIndex = @legIndex

END
GO
