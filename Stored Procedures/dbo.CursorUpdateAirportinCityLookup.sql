SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 29th Sep 2014
-- Description:	This procedure is used to update airport codes of cities in CityLookup2 table from CityNeighboringAirportLookup
-- =============================================
CREATE PROCEDURE [dbo].[CursorUpdateAirportinCityLookup]
	
AS
BEGIN
	DECLARE @cityKey INT
	DECLARE @airportCode VARCHAR(5)

	DECLARE @cityLookupCursor CURSOR
	SET @cityLookupCursor = CURSOR FOR
	SELECT cityKey
	FROM vault..cityLookup2

	OPEN @cityLookupCursor
	FETCH NEXT
	FROM @cityLookupCursor INTO @cityKey
	WHILE @@FETCH_STATUS = 0
	BEGIN	
		
		UPDATE [vault].dbo.CityLookup2 
		SET AirportCode = (SELECT TOP 1 airport FROM [Trip].[dbo].[CityNeighboringAirportLookup] WHERE cityKey = @cityKey ORDER BY distance)
		WHERE cityKey = @cityKey	

	FETCH NEXT
	FROM @cityLookupCursor INTO @cityKey
	END

	CLOSE @cityLookupCursor
	DEALLOCATE @cityLookupCursor
END
GO
