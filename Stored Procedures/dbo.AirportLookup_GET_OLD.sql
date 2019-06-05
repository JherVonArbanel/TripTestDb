SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirportLookup_GET_OLD]
(
	@prefixText			VARCHAR(100),
	@toGetCountryCode	INT = 0
)
AS
BEGIN
	
	IF @toGetCountryCode = 0
	BEGIN
		
		IF LEN(@prefixText)=3
		BEGIN
			
			SELECT 
				AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode 
			FROM AirportLookup 
			WHERE AirportCode = @prefixText 
		END
		ELSE
		BEGIN
			SELECT 
				AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) and AirStatus =0 order by AirPriority asc
		END		
	END
	ELSE
	BEGIN
		IF LEN(@prefixText) = 3
		BEGIN
			SELECT CountryCode 
			FROM AirportLookup 
			WHERE AirportCode = @prefixText	
		END
		ELSE
		BEGIN
			SELECT CountryCode 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%' + @prefixText + '%') OR CityName LIKE ('%'+ @prefixText +'%')) and AirStatus=0  order by AirPriority asc
		END		
	END	
END
GO
