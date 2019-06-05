SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Pradeep Gupta>
-- Create date: <2-aug-2016>
-- Description:	<to get all the destination provided by Brian/steve/rick for hashtag autocomplete >
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAllDestinationForHashTagAutocomlete]

AS
BEGIN

	Select distinct LOWER(REPLACE(CityName,' ','')) as [Destination]  from trip..AirportLookup where AirportCode in (
	SELECT DISTINCT Origin FROM TRIP..HOTELCACHEDATA WITH (NOLOCK) 
	)

END
GO
