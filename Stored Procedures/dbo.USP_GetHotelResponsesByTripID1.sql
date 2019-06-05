SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesByTripID1]
(
	@tripKey			INT = NULL,
	@hotelResponseKey	UNIQUEIDENTIFIER
)
AS
BEGIN

	IF @tripKey IS NOT NULL
	BEGIN
		SELECT 
			vw_hotelDetailedResponse1.*, 
			Trip_hotelResponse.* 
		FROM vw_hotelDetailedResponse1 
			LEFT OUTER JOIN Trip_hotelResponse ON vw_hotelDetailedResponse1.hotelResponseKey = Trip_hotelResponse.hotelResponseKey 
		WHERE tripKey = @tripKey
	END
	ELSE
	BEGIN
		SELECT * FROM vw_hotelDetailedResponse1 WHERE hotelResponseKey = @hotelResponseKey
	END

END
GO
