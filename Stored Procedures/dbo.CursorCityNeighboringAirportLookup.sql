SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 06-12-2013 15:41
-- Description:	City Neighboring Airportport lookup table popultaion with distance
-- =============================================
CREATE PROCEDURE [dbo].[CursorCityNeighboringAirportLookup]
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @airportCode varchar(3)
    DECLARE @latitude float
    DECLARE @longitude float
    DECLARE @countryCode varchar(10)
    DECLARE @cityName varchar(200)
    

	DECLARE airportCode_cursor1 CURSOR FOR 
	SELECT  AirportCode, Latitude, Longitude, CountryCode
	FROM [Trip].[dbo].[AirportLookup]  WHERE Preference = 1

	TRUNCATE TABLE [Trip].[dbo].[CityNeighboringAirportLookup]
	
	OPEN airportCode_cursor1

	FETCH NEXT FROM airportCode_cursor1 INTO @airportCode, @latitude, @longitude, @countryCode

	WHILE @@FETCH_STATUS = 0
	BEGIN
		
		INSERT INTO [Trip].[dbo].[CityNeighboringAirportLookup]
		SELECT  A.cityKey, A.cityName, A.latitude, A.longitude, HotelContent.dbo.fnGetDistance(@latitude, @longitude, A.Latitude, A.Longitude, 'Miles') Distance, @airportCode
		FROM [Vault].[dbo].[CityLookup2] A 
		WHERE A.CountryCode = @countryCode

		FETCH NEXT FROM airportCode_cursor1 INTO @airportCode, @latitude, @longitude, @countryCode
		
	END

	CLOSE airportCode_cursor1
	DEALLOCATE airportCode_cursor1

END
GO
