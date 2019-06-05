SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelSegmentByID]
(
	@hotelResponseDetailKey	UNIQUEIDENTIFIER
)
AS
BEGIN

	SELECT * FROM HotelResponseDetail WHERE hotelResponseDetailKey = @hotelResponseDetailKey

END
GO
