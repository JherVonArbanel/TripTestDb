SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[Get_Airport_List]
(
	@prefixText   VARCHAR(100),    
	@toGetCountryCode INT = 0    
)AS    
BEGIN    
    
	DECLARE @myString VARCHAR(400)    
	DECLARE @sCount INT
	DECLARE @iCount INT    
	DECLARE @spart VARCHAR(200)     
    
	DECLARE @tblAirport AS TABLE
	(
		AirportName varchar(200), 
		CityName varchar(200), 
		StateCode varchar(50), 
		CountryCode varchar(50), 
		AirportCode varchar(50), 
		AirPriority tinyint 
	) 

	IF @toGetCountryCode = 0    
	BEGIN      
		IF LEN(@prefixText)=3      
		BEGIN    
			INSERT INTO @tblAirport 
			SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
			FROM AirportLookup 
			WHERE AirportCode = @prefixText    
			
			INSERT INTO @tblAirport 
			SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
			FROM AirportLookup 
			WHERE AirportCode <> @prefixText AND (CityName LIKE (@prefixText +'%')) AND CityCode = @prefixText AND AirStatus =0 
			ORDER BY AirPriority, Citycode, CityName ASC 
      
			SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
			FROM @tblAirport  
			ORDER BY AirPriority, AirportCode ASC 
		END    
		ELSE    
		BEGIN    
			INSERT INTO @tblAirport 
			SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) AND AirStatus = 0 
			ORDER BY AirPriority ASC 
			
			IF (SELECT COUNT(*) FROM @tblAirport) = 0 
			BEGIN 
				SET @myString = @prefixText    
				SELECT @iCount = CHARINDEX(' ', @myString, 0) 

				IF @iCount > 0 
				BEGIN 
					SET @sCount = 1 
					While @sCount > 0 
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
							OR CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END)) AND AirStatus = 0 
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
			--and (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ( @prefixText +'%')) and AirStatus =0 order by AirPriority asc 
		END    
		ELSE    
		BEGIN    
			DECLARE @tblCountryCode AS TABLE 
			( 
				CountryCode VARCHAR(50) 
			) 

			INSERT INTO @tblCountryCode 
			SELECT CountryCode FROM AirportLookup WHERE (AirportName LIKE ('%' + @prefixText + '%')) AND AirStatus = 0 ORDER BY AirPriority ASC 

			IF (SELECT COUNT(*) FROM @tblCountryCode) = 0 
			BEGIN 
				SET @myString = @prefixText    
				Select @iCount = charindex(' ',@myString,0) 

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
       
						INSERT INTO @tblCountryCode 
						SELECT CountryCode 
						FROM AirportLookup 
						WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END) 
							OR CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END)) AND AirStatus = 0 
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
