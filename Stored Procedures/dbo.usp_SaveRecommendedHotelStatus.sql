SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[usp_SaveRecommendedHotelStatus]
(
	@eventKey BIGINT,
	@isRecommendedHotel BIT,
	@eventRecommendedHotelId BIGINT
)
AS
BEGIN

	UPDATE [Events]
	SET IsRecommendingHotel = @isRecommendedHotel,
		eventRecommendedHotelId = @eventRecommendedHotelId
	WHERE
	eventKey = @eventKey
	

END
GO
