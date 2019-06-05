SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
--exec [AirportLookup_GET_Star_Advanced] 'san  f'
CREATE PROCEDURE [dbo].[AirportLookup_GET_Star_Advanced] 
(    
 @prefixText   VARCHAR(100),    
 @toGetCountryCode INT = 0
)AS    
BEGIN    
    
 DECLARE @myString VARCHAR(400)    
 DECLARE @sCount INT    
 DECLARE @iCount INT    
 DECLARE @spart VARCHAR(200)     
 --DECLARE @RowCountHotelAddress INT    
 --DECLARE @RowCountZipCode INT    
    
 DECLARE @tblAirport AS TABLE  
 (    
  AirportName  VARCHAR(500),    
  CityName  VARCHAR(200),    
  StateCode  VARCHAR(50),    
  CountryCode  VARCHAR(50),    
  AirportCode  VARCHAR(50),    
  AirPriority  TINYINT,
  AirOrder INT ,
  Latitude  float default(0),
  Longitude  float default(0),
  CityCode VARCHAR(3)
 )    
   
 SET @prefixText = LTRIM(RTRIM(@prefixText))  
       
 --IF @toGetCountryCode = 0    
 --BEGIN

IF LEN(@prefixText)=3      
	BEGIN    
		INSERT INTO @tblAirport   		   
		   SELECT REPLACE(AirportName,',',''), CityName, StateCode, CountryCode, AirportCode, AirPriority, 1  ,NULL,NULL,NULL  
		   FROM AirportLookup     
		   WHERE AirportCode = @prefixText AND Preference = 1   AND IsVisible = 1  
     
		   INSERT INTO @tblAirport   
		   SELECT REPLACE(AirportName,',',''), CityName, StateCode, CountryCode, AirportCode, AirPriority, 2 ,NULL,NULL,NULL    
		   FROM AirportLookup    
		   WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) 
				and AirStatus =0 AND Preference = 1 AND IsVisible = 1 --AND gmt_offset IS NOT NULL     
		   ORDER BY AirPriority ASC   
		   
		   -- MIN Order set 3 for Address And Zip Code 
		   -- Getting On the Basis of Address 
		   INSERT INTO @tblAirport(AirportName,AirOrder,Latitude,Longitude,CityCode)
		   SELECT DisplayTextWithoutAirport,3,Latitude,Longitude,AirportCode 
		   FROM HotelAutoCompleteForAddressSearch
		   WHERE CityName LIKE @prefixText + '%'
		   ORDER BY DisplayTextWithoutAirport
		   
		   INSERT INTO @tblAirport(AirportName,AirOrder,Latitude,Longitude,CityCode)
		   SELECT DisplayTextWithoutAirport,4,Latitude,Longitude,AirportCode 
		   FROM HotelAutoCompleteForAddressSearch
		   WHERE CityName LIKE '%' + @prefixText + '%'
		   ORDER BY DisplayTextWithoutAirport
		   
		   -- Getting On the Basis of Postal Code
		   INSERT INTO @tblAirport(AirportName,AirOrder,CityCode)
		   SELECT DisplayText,3,CityCode 
		   FROM HotelAutoCompleteForZipCodeSearch
		   WHERE ZipCode LIKE  @prefixText + '%'
		   ORDER BY DisplayText
		   
		   INSERT INTO @tblAirport(AirportName,AirOrder,CityCode)
		   SELECT DisplayText,4,CityCode 
		   FROM HotelAutoCompleteForZipCodeSearch
		   WHERE ZipCode LIKE '%' + @prefixText + '%'
		   ORDER BY DisplayText
          
		   SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority ,Latitude,Longitude,CityCode    
		   FROM @tblAirport    
		   GROUP BY AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority,Latitude,Longitude,CityCode
		   ORDER BY MIN(AirOrder)   
	END    
	ELSE    
	BEGIN    
	   INSERT INTO @tblAirport   
		   SELECT REPLACE(AirportName,',','') AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 1   ,NULL,NULL,NULL   
		   FROM AirportLookup    
		   WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) and AirStatus =0 AND Preference = 1  AND IsVisible = 1 
		   ORDER BY AirPriority ASC  
		    
		    --SELECT @RowCountHotelAddress= COUNT(DisplayTextWithoutAirport)FROM HotelAutoCompleteForAddressSearch WHERE CityName LIKE '%' + @prefixText + '%' 
		    --SELECT @RowCountZipCode= COUNT(DisplayText) FROM HotelAutoCompleteForZipCodeSearch WHERE ZipCode LIKE '%' + @prefixText + '%' 
		    
		    --print 'hotel address rows' + convert(varchar(100),@RowCountHotelAddress)
		    --print 'zip code rows' + convert(varchar(100),@RowCountZipCode)
		    
		   -- Getting On the Basis of Address 
		   INSERT INTO @tblAirport(AirportName,AirOrder,Latitude,Longitude,CityCode)
		   SELECT DisplayTextWithoutAirport,3 ,Latitude,Longitude,AirportCode
		   FROM HotelAutoCompleteForAddressSearch
		   WHERE CityName LIKE @prefixText + '%'
		   ORDER BY DisplayTextWithoutAirport
		   
		   INSERT INTO @tblAirport(AirportName,AirOrder,Latitude,Longitude,CityCode)
		   SELECT DisplayTextWithoutAirport,4 ,Latitude,Longitude,AirportCode
		   FROM HotelAutoCompleteForAddressSearch
		   WHERE CityName LIKE '%' + @prefixText + '%'
		   ORDER BY DisplayTextWithoutAirport
		   
		   -- Getting On the Basis of Postal Code
		   INSERT INTO @tblAirport(AirportName,AirOrder,CityCode)
		   SELECT DisplayText,3,CityCode 
		   FROM HotelAutoCompleteForZipCodeSearch
		   WHERE ZipCode LIKE  @prefixText + '%'
		   ORDER BY DisplayText
		   
		   INSERT INTO @tblAirport(AirportName,AirOrder,CityCode)
		   SELECT DisplayText,4,CityCode 
		   FROM HotelAutoCompleteForZipCodeSearch
		   WHERE ZipCode LIKE '%' + @prefixText + '%'
		   ORDER BY DisplayText
		      
	   IF (SELECT COUNT(*) FROM @tblAirport) = 0  --or (@RowCountHotelAddress =0 or @RowCountZipCode = 0)  
	   BEGIN   
		WHILE CHARINDEX('  ', @prefixText, 0) > 0  -- First Removing Double Space with Single Space
		BEGIN  
		 SET @prefixText = REPLACE(@prefixText, '  ', ' ')  
		END  
      PRINT 'IN THIS LOOP'
		SET @myString = @prefixText -- Then keep that text into @mystring
		SELECT @iCount = CHARINDEX(' ', @myString, 0) -- Set Index of First Space Encountered
      
		IF @iCount > 0    -- If any space is there then 
		BEGIN    
		 SET @sCount = 1   -- First time Loop will run 
		 WHILE @sCount > 0    
		 BEGIN  
		 --print 'Text = '+ @myString  
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
		  SELECT REPLACE(AirportName,',',''), CityName, StateCode, CountryCode, AirportCode, AirPriority, 2 ,NULL,NULL,NULL     
		  FROM AirportLookup     
		  WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END) OR   
		   CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END)) AND AirStatus = 0  AND IsVisible = 1   
		  ORDER BY AirPriority ASC 
		  
		  
		  -- Getting On the Basis of Address 
		   INSERT INTO @tblAirport(AirportName,AirOrder,Latitude,Longitude,CityCode)
		   SELECT DisplayTextWithoutAirport ,
		   CASE @scount WHEN 1 THEN 3 ELSE 4 END,
		   Latitude,Longitude,AirportCode
		   FROM HotelAutoCompleteForAddressSearch
		   WHERE
		   --CITYNAME LIKE '%'+@prefixText+'%' OR CITYNAME LIKE '%'+SUBSTRING(@prefixText, 0, @iCount)+'%'
		   (CITYNAME LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END))
		   ORDER BY DisplayTextWithoutAirport
		   
		   -- Getting On the Basis of Postal Code
		   INSERT INTO @tblAirport(AirportName,AirOrder,CityCode)
		   SELECT DisplayText,
		   CASE @scount WHEN 1 THEN 3 ELSE 4 END,
		   CityCode 
		   FROM HotelAutoCompleteForZipCodeSearch
		   WHERE
		   --ZipCode LIKE '%'+@prefixText+'%' OR ZipCode LIKE '%'+SUBSTRING(@prefixText, 0, @iCount)+'%'
		   (ZipCode LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END))
		   ORDER BY DisplayText
		      
		  SELECT @iCount = CHARINDEX(' ', @myString, 0)      
		  SET @sCount = LEN(@myString)   
		 END     
		END    
	   END    
---  select * FROM @tblAirport   
	   SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority  ,Latitude,Longitude,CityCode  
	   FROM @tblAirport   
	   GROUP BY AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority,Latitude,Longitude,CityCode
		ORDER BY MIN(AirOrder)          
  END    
       
DELETE FROM @tblAirport    
   
END
GO
