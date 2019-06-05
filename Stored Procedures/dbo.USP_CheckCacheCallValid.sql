SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_CheckCacheCallValid] 
(	
@cabinType varchar(20),
@tripType varchar(20),
@departureDate DateTime,
@arrivalDate DateTime = NULL,
@travelerCount int,
@departCountry varchar(3),
@arrivalCountry varchar(3),
@departureAirport varchar(50),
@arrivalAirport varchar(50),
@isRestrictedFare bit = 1
)
AS
BEGIN
	IF(UPPER(@cabinType) = 'ECONOMY' AND UPPER(@tripType) = 'ROUNDTRIP' AND @isRestrictedFare = 1)
	BEGIN
		IF(DATEDIFF(DAY, @departureDate,@arrivalDate) <= 16)
		BEGIN
		IF(DATEDIFF(DAY,GETDATE(),@departureDate) <= 192)
			BEGIN
				IF(@travelerCount <= 9)
				BEGIN
					IF EXISTS(select 1 from vault.dbo.CityPairsLookup where (OriginAirportCode = @departureAirport AND DestinationAirportCode = @arrivalAirport AND OriginCountryCode = @departCountry AND DestinationCountryCode = @arrivalCountry))
					BEGIN
						SELECT 1
					END
					ELSE
					BEGIN
						SELECT 0
					END
				END
				ELSE
				BEGIN
					SELECT 0
				END
			END
			ELSE
			BEGIN
				SELECT 0
			END
		END
		ELSE
		BEGIN
			SELECT 0
		END
	END
	ELSE
	BEGIN
		SELECT 0
	END
END 


GO
