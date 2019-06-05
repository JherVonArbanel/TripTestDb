SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetHotelResponsesTripSavedDeals]
(
	@hotelRequestKey	INT,
	@hotelResponseKey	UNIQUEIDENTIFIER,
	@hotelID			INT = 0
)
AS
BEGIN
   IF @hotelRequestKey IS NOT NULL
	BEGIN
		SELECT * FROM vw_hotelDetailedResponseDeals WHERE hotelRequestKey = @hotelRequestKey
	END
	ELSE IF @hotelID <> 0
	BEGIN
		SELECT top 100 * FROM vw_hotelDetailsNew WHERE hotelID = @hotelID
	END
	ELSE 
	BEGIN
		SELECT top 100 * FROM vw_hotelDetailedResponseDeals WHERE hotelResponseKey = @hotelResponseKey
	END
	

END
GO
