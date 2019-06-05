SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,SELECT HotelResponseDetail table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetHotelComRoomRules]
@hotelResponseDetailKey uniqueidentifier

AS
BEGIN
 
SELECT * FROM HotelResponseDetail where hotelResponseDetailKey = @hotelResponseDetailKey

END
GO
