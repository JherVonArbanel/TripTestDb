SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[sp_GetHotelMatrixDetails]
(
	@HotelRequestKey NVARCHAR(1000)
)
AS
	Select Top 10 * from vw_hotelResponseDetail where 
	HotelRequestKey = @HotelRequestKey and Rating >= 3 order by minRate
GO
