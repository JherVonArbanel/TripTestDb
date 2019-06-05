SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,INSERT INTO HotelRequest table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_AddHotelTravelComponentRequest]

	@hotelCityCode			NCHAR(3), 
	@checkInDate			DATETIME, 
	@checkOutDate			DATETIME, 
	@hotelRequestCreated	DATETIME, 
	@hotelAddress			NVARCHAR(200)

AS
BEGIN
 
	INSERT INTO HotelRequest (hotelCityCode, checkInDate, checkOutDate, hotelRequestCreated, hotelAddress)
	VALUES (@hotelCityCode, @checkInDate, @checkOutDate, @hotelRequestCreated, @hotelAddress) 
	
	SELECT SCOPE_IDENTITY()

END
GO
