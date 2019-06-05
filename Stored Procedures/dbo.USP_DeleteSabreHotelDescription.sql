SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_DeleteSabreHotelDescription]
(
	@hotelResponseKey	UNIQUEIDENTIFIER
)
AS
BEGIN

	DELETE FROM HotelResponseDetail WHERE hotelResponseKey = @hotelResponseKey and supplierId ='Sabre'

END
GO
