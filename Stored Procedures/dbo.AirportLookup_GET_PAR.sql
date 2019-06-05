SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirportLookup_GET_PAR]
(
	@prefixText			VARCHAR(100),
	@toGetCountryCode	INT = 0
)
AS
BEGIN

	DECLARE @myString VARCHAR(400)
	DECLARE @sCount INT
	DECLARE @iCount INT
	DECLARE @spart VARCHAR(200)	

	IF @toGetCountryCode = 0
	BEGIN		
		IF LEN(@prefixText)=3  
		BEGIN
			SELECT 
				AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode,
				AirPriority 
			FROM AirportLookup 
			WHERE AirportCode = @prefixText 
		END
		ELSE
		BEGIN
			DECLARE @tblAirport AS TABLE
			(
				AirportName VARCHAR(200),
				CityName VARCHAR(200),
				StateCode VARCHAR(50),
				CountryCode VARCHAR(50),
				AirportCode VARCHAR(50),
				AirPriority TINYINT 
			)
			
			INSERT INTO @tblAirport 
			SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) AND AirStatus = 0 
			ORDER BY AirPriority ASC
			
			IF (SELECT COUNT(*) FROM @tblAirport) = 0
			BEGIN
				SET @myString = @prefixText
				SELECT @iCount = CHARINDEX(' ',@myString,0)
				IF @iCount > 0
				BEGIN
					SET @sCount = 1
					WHILE @sCount > 0
					BEGIN
						IF(@iCount > 0)
						BEGIN
							SELECT @spart = SUBSTRING(@myString, 0, @iCount)	
							SELECT @myString = SUBSTRING(@mystring, @iCount + 1, LEN(@myString) - @iCount)
						END
						ELSE 
						BEGIN
							SET @spart = @myString
							SET @myString = ''
						END
							INSERT INTO @tblAirport 
							SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
							FROM AirportLookup 
							WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END) 
								OR CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END)) 
								AND AirStatus = 0 
							ORDER BY AirPriority ASC
							
							SELECT @iCount = CHARINDEX(' ', @myString, 0) 
							SET @sCount = LEN(@myString) 
					END 
				END
			END
			SELECT DISTINCT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority  
			FROM @tblAirport 
			ORDER BY AirPriority ASC
				
			DELETE FROM @tblAirport
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
			DECLARE @tblCountryCode AS TABLE(CountryCode VARCHAR(50))
			INSERT INTO @tblCountryCode 
			SELECT CountryCode 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%' + @prefixText + '%') OR CityName LIKE ('%'+ @prefixText +'%')) AND AirStatus = 0 
			ORDER BY AirPriority ASC
			IF (SELECT COUNT(*) FROM @tblCountryCode) = 0
			BEGIN
				SET @myString = @prefixText
				SELECT @iCount = CHARINDEX(' ', @myString, 0)
				IF @iCount > 0
				BEGIN
					SET @sCount = 1
					WHILE @sCount > 0
					BEGIN
						IF(@iCount > 0)
						BEGIN
							SELECT @spart = SUBSTRING(@myString, 0, @iCount)	
							SELECT @myString = substring(@mystring, @iCount + 1, LEN(@myString) - @iCount)
						END
						ELSE 
						BEGIN
							SET @spart = @myString
							SET @myString = ''
						END

						INSERT INTO @tblCountryCode 
						SELECT CountryCode 
						FROM AirportLookup 							
						WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END) 
							OR CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END))
							AND AirStatus = 0 
						ORDER BY AirPriority ASC
						
						SELECT @iCount = CHARINDEX(' ', @myString, 0)		
						SET @sCount = LEN(@myString) 
					END 
				END
			END
			SELECT DISTINCT * FROM @tblCountryCode 
			
			DELETE FROM @tblAirport
		END		
	END	
END
GO
