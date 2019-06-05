SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
    
Create PROCEDURE [dbo].[AirportLookup_GET_NotWorkingForStarAllianceProject_April0913]    
(      
 @prefixText   VARCHAR(100),      
 @toGetCountryCode INT = 0,  
 @cmsHotelGroup bit = 0  
)AS      
BEGIN      
      
 DECLARE @myString VARCHAR(400)      
 DECLARE @sCount INT      
 DECLARE @iCount INT      
 DECLARE @spart VARCHAR(200)       
      
 DECLARE @tblAirport AS TABLE    
 (      
  AirportName  VARCHAR(200),      
  CityName  VARCHAR(200),      
  StateCode  VARCHAR(50),      
  CountryCode  VARCHAR(50),      
  AirportCode  VARCHAR(50),      
  AirPriority  TINYINT,  
  AirOrder INT       
 )      
     
 SET @prefixText = LTRIM(RTRIM(@prefixText))    
         
 --IF @toGetCountryCode = 0      
 --BEGIN  
  
IF (@cmsHotelGroup = 0)  
BEGIN  
 IF LEN(@prefixText)=3        
 BEGIN      
  INSERT INTO @tblAirport     
     SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 1       
     FROM AirportLookup       
     WHERE AirportCode = @prefixText      
       
   --INSERT INTO @tblAirport     
   --SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority       
   --FROM AirportLookup       
   --WHERE AirportCode <> @prefixText AND (CityName LIKE (@prefixText +'%')) AND CityCode = @prefixText     
   -- AND AirStatus =0     
   --ORDER BY AirPriority,Citycode,CityName ASC     
            
     SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority       
     FROM @tblAirport      
     ORDER BY AirPriority, AirportCode ASC    
 END      
 ELSE      
 BEGIN      
    INSERT INTO @tblAirport     
     SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 2       
     FROM AirportLookup      
     WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) and AirStatus =0     
     ORDER BY AirPriority ASC     
    
  --  IF (SELECT COUNT(*) FROM @tblAirport) = 0      
  --  BEGIN     
  --WHILE CHARINDEX('  ', @prefixText, 0) > 0    
  --BEGIN    
  -- SET @prefixText = REPLACE(@prefixText, '  ', ' ')    
  --END    
        
  --SET @myString = @prefixText    
  --SELECT @iCount = CHARINDEX(' ', @myString, 0)      
        
  --IF @iCount > 0      
  --BEGIN      
  -- SET @sCount = 1      
  -- WHILE @sCount > 0      
  -- BEGIN      
  --  IF(@iCount > 0)      
  --  BEGIN     
  --   SELECT @spart = SUBSTRING(@myString, 0, @iCount)             
  --   SELECT @myString = SUBSTRING(@mystring, @iCount + 1, LEN(@myString) - @iCount)     
  --  END      
  --  ELSE       
  --  BEGIN      
  --   SET @spart = @myString      
  --   SET @myString = ''      
  --  END      
     
  --  INSERT INTO @tblAirport     
  --  SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 3       
  --  FROM AirportLookup       
  --  WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END) OR     
  --   CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END)) AND AirStatus = 0     
  --  ORDER BY AirPriority ASC     
           
  --  SELECT @iCount = CHARINDEX(' ', @myString, 0)        
  --  SET @sCount = LEN(@myString)     
  -- END       
  --END      
  --  END      
    
    SELECT DISTINCT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority      
    FROM @tblAirport     
    ORDER BY AirPriority ASC              
  END      
END  
ELSE  
BEGIN  
     
    INSERT INTO @tblAirport     
     SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 1       
     FROM AirportLookup       
     WHERE AirportCode = @prefixText AND Preference = 1 --AND gmt_offset IS NOT NULL     
                 
    INSERT INTO @tblAirport     
    SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 2       
    FROM AirportLookup      
    WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%'))   
   and AirStatus =0 AND Preference = 1 --AND gmt_offset IS NOT NULL       
    ORDER BY AirPriority ASC     
     
  --  IF (SELECT COUNT(*) FROM @tblAirport) = 0      
  --  BEGIN     
  --WHILE CHARINDEX('  ', @prefixText, 0) > 0    
  --BEGIN    
  -- SET @prefixText = REPLACE(@prefixText, '  ', ' ')    
  --END    
         
  --SET @myString = @prefixText    
  --SELECT @iCount = CHARINDEX(' ', @myString, 0)      
         
  --IF @iCount > 0      
  --BEGIN      
  -- SET @sCount = 1      
  -- WHILE @sCount > 0      
  -- BEGIN      
  --  IF(@iCount > 0)      
  --  BEGIN     
  --   SELECT @spart = SUBSTRING(@myString, 0, @iCount)             
  --   SELECT @myString = SUBSTRING(@mystring, @iCount + 1, LEN(@myString) - @iCount)     
  --  END      
  --  ELSE       
  --  BEGIN      
  --   SET @spart = @myString      
  --   SET @myString = ''      
  --  END      
     
  --  INSERT INTO @tblAirport     
  --  SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, 3       
  --  FROM AirportLookup       
  --  WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END) OR     
  --   CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END))   
  --   AND AirStatus = 0 AND Preference = 1 --AND gmt_offset IS NOT NULL     
  --  ORDER BY AirPriority ASC     
           
  --  SELECT @iCount = CHARINDEX(' ', @myString, 0)        
  --  SET @sCount = LEN(@myString)     
  -- END       
  --END      
  --  END            
      
  SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority  
  FROM @tblAirport   
  GROUP BY AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority  
  ORDER BY MIN(AirOrder)                  
   --END   
     
   SELECT HG.HotelGroupId,HG.HotelGroupName,HG.AirportCode  
   , HG.HotelGroupName + ' [' + HG.AirportCode + ']'   
  FROM   
   @tblAirport TA INNER JOIN [CMS].[dbo].[CustomHotelGroup] HG ON TA.AirportCode = HG.AirportCode   
  WHERE   
   HG.Visible = 1    
  UNION  
  SELECT HG.HotelGroupId,HG.HotelGroupName,HG.AirportCode  
   , HG.HotelGroupName + ' [' + HG.AirportCode + ']'    
  FROM   
   [CMS].[dbo].[CustomHotelGroup] HG   
  WHERE   
   LEN(@prefixText) > 3 AND  
   HG.Visible = 1 AND  
   HG.HotelGroupName LIKE '%'+@prefixText+'%'    
END         
DELETE FROM @tblAirport      
  
 --END      
 --ELSE      
 --BEGIN      
 -- IF LEN(@prefixText) = 3      
 -- BEGIN      
 --  SELECT CountryCode FROM AirportLookup WHERE AirportCode = @prefixText     
 --  --and (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ( @prefixText +'%')) and AirStatus =0 order by AirPriority asc      
 -- END      
 -- ELSE      
 -- BEGIN      
 --  DECLARE @tblCountryCode AS TABLE(CountryCode VARCHAR(50))      
 --  INSERT INTO @tblCountryCode     
 --  SELECT CountryCode     
 --  FROM AirportLookup     
 --  WHERE (AirportName LIKE ('%' + @prefixText + '%') OR CityName LIKE ('%'+ @prefixText +'%'))     
 --   AND AirStatus = 0      
 --  ORDER BY AirPriority ASC     
    
 --  IF (SELECT COUNT(*) FROM @tblCountryCode) = 0      
 --  BEGIN    
 --   WHILE CHARINDEX('  ', @prefixText, 0) > 0    
 --   BEGIN    
 --    SET @prefixText = REPLACE(@prefixText, '  ', ' ')    
 --   END    
        
 --   SET @myString = @prefixText    
 --   SELECT @iCount = CHARINDEX(' ', @myString, 0)      
 --   IF @iCount > 0      
 --   BEGIN      
 --    SET @sCount = 1      
 --    WHILE @sCount > 0      
 --    BEGIN      
 --     IF(@iCount > 0)      
 --     BEGIN     
 --      SELECT @spart = SUBSTRING(@myString, 0, @iCount)       
 --      SELECT @myString = SUBSTRING(@mystring, @iCount + 1, LEN(@myString) - @iCount)     
 --     END     
 --     ELSE       
 --     BEGIN      
 --      SET @spart = @myString      
 --      SET @myString = ''      
 --     END      
    
 --     INSERT INTO @tblCountryCode     
 --     SELECT CountryCode     
 --     FROM AirportLookup     
 --     WHERE (AirportName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END)     
 --      OR CityName LIKE (CASE @sCount WHEN 1 THEN (@spart +' %') ELSE ('%' + @spart +'%') END))      
 --      AND AirStatus = 0     
 --     ORDER BY AirPriority ASC     
    
 --   SELECT @iCount = CHARINDEX(' ', @myString, 0)     
 --     SET @sCount = LEN(@myString)     
 --    END       
 --   END      
 --  END      
 --  SELECT DISTINCT * FROM @tblCountryCode       
 --  DELETE FROM @tblAirport      
 -- END        
 --END       
END
GO
