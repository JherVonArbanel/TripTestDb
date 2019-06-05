SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelResponses1]
(
	@hotelRequestKey	INT,
	@hotelResponseKey	UNIQUEIDENTIFIER,
	@hotelID			INT = 0
)
AS
BEGIN
   IF @hotelRequestKey IS NOT NULL
	BEGIN
		SELECT * FROM vw_hotelDetailedResponse WHERE hotelRequestKey = @hotelRequestKey
	END
	ELSE IF @hotelID <> 0
	BEGIN
		SELECT top 100 * FROM vw_hotelDetails WHERE hotelID = @hotelID
	END
	ELSE 
	BEGIN
		SELECT top 100 * FROM vw_hotelDetailedResponse WHERE hotelResponseKey = @hotelResponseKey
	END
	

END
GO
