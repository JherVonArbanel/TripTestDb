SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 28-11-2013 14:35
-- Description:	Neighboring Airportport lookup table popultaion with distance
-- =============================================
CREATE PROCEDURE [dbo].[CursorNeighboringAirportLookup]
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @airportCode varchar(3)
    DECLARE @latitude float
    DECLARE @longitude float
    DECLARE @countryCode varchar(10)

	DECLARE airportCode_cursor CURSOR FOR 
	SELECT  AirportCode, Latitude, Longitude, CountryCode
	FROM [Trip].[dbo].[AirportLookup]  WHERE Preference = 1

	TRUNCATE TABLE [Trip].[dbo].[NeighboringAirportLookup]
	
	OPEN airportCode_cursor

	FETCH NEXT FROM airportCode_cursor INTO @airportCode, @latitude, @longitude, @countryCode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		INSERT INTO [Trip].[dbo].[NeighboringAirportLookup]
		SELECT  @airportCode, A.AirportCode, HotelContent.dbo.fnGetDistance(@latitude, @longitude, A.Latitude, A.Longitude, 'Miles') Distance
		FROM [Trip].[dbo].[AirportLookup] A 
		WHERE A.CountryCode = @countryCode AND Preference = 1

		FETCH NEXT FROM airportCode_cursor INTO @airportCode, @latitude, @longitude, @countryCode
		
	END

	CLOSE airportCode_cursor
	DEALLOCATE airportCode_cursor

END
GO
