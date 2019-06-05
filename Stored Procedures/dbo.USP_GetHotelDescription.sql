SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Create date: <22/8/2012>
-- Description:	<Used to check if response exists in HotelDescription table>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetHotelDescription] 
	@hotelResponseKey UNIQUEIDENTIFIER  
AS
BEGIN
	select hotelResponseKey from HotelDescription where hotelResponseKey=@hotelResponseKey
END
GO
