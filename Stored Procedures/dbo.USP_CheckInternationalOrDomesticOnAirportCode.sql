SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ashima Gupta
-- Create date: 14th Jan 2016
-- Description:	Checks is International or Domestic on the basis of Airport Code
-- =============================================
CREATE PROCEDURE [dbo].[USP_CheckInternationalOrDomesticOnAirportCode] 
	
	@departureAirport varchar(20)
	,@arrivalAirport varchar(20)
	
AS
BEGIN	
	SET NOCOUNT ON;
	
	DECLARE @CountryCode varchar(2)
	DECLARE @isInternational bit =0
	
	SELECT @CountryCode = CountryCode From AirportLookup where AirportCode = @arrivalAirport		
	IF(@CountryCode != 'US')
		BEGIN
			SET @isInternational = 1
			SELECT isInternational = @isInternational
			RETURN
		END
		ELSE
			BEGIN
				SELECT @CountryCode = CountryCode From AirportLookup where AirportCode = @departureAirport
				IF(@CountryCode != 'US')
					BEGIN
						SET @isInternational = 1
						SELECT isInternational = @isInternational
						RETURN
					END
					ELSE
						SELECT isInternational = @isInternational
						RETURN
		END
	
	
END
GO
