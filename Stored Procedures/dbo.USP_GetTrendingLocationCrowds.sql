SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Vivek Upadhyay>
-- Create date: <06-Mar-2017>
-- Description:	<Get location wise trip trending list>
-- Exec USP_GetTrendingLocationCrowds
-- =============================================
CREATE PROC [dbo].[USP_GetTrendingLocationCrowds]
(
@LocationKey INT = 0
)
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT * FROM HotelCacheData WHERE Origin in(SELECT AirportCode FROM RegionAirportGroup WHERE GroupNumber=@LocationKey)
	
END
GO
