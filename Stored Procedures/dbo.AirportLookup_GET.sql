SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[AirportLookup_GET]    
(      
 @prefixText   VARCHAR(100),      
 @toGetCountryCode INT = 0,  
 @cmsHotelGroup bit = 0  
)AS      
BEGIN 
    DECLARE @myString AS VARCHAR (400);
    DECLARE @sCount AS INT;
    DECLARE @iCount AS INT;
    DECLARE @spart AS VARCHAR (200);
    DECLARE @rows1 AS INT;
    DECLARE @rows2 AS INT ;
    DECLARE @tblAirport AS TABLE (
        AirportName VARCHAR (200),
        CityName    VARCHAR (200),
        StateCode   VARCHAR (50) ,
        CountryCode VARCHAR (50) ,
        AirportCode VARCHAR (50) ,
        AirPriority TINYINT      ,
        AirOrder    INT          ,
        CountryName VARCHAR (50) ,
        CityGroupKey       INT,
        CountryPriority INT 
         );
         
 DECLARE @tblHotelGroup AS TABLE (
        HotelGroupId INT,
        HotelGroupName VARCHAR (200),
        AirportCode VARCHAR (50) ,
        HotelGroupNameText VARCHAR (300)
         );         
    SET @prefixText = REPLACE(LTRIM(RTRIM(@prefixText)), '.', '');
    --IF @toGetCountryCode = 0      
    --BEGIN  
    IF (@cmsHotelGroup = 0)
        BEGIN
            IF LEN(@prefixText) = 3
                BEGIN
                    INSERT INTO @tblAirport
                    SELECT AirportName,
                           CityName,
                           StateCode,
                           CountryCode,
                           AirportCode,
                           AirPriority,
                           1,
                           CountryName,
                           0,
                           CountryPriority
                    FROM   AirportLookup WITH (NOLOCK)
                    WHERE  AirportCode = @prefixText;
                    --INSERT INTO @tblAirport     
                    --SELECT AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority       
                    --FROM AirportLookup       
                    --WHERE AirportCode <> @prefixText AND (CityName LIKE (@prefixText +'%')) AND CityCode = @prefixText     
                    -- AND AirStatus =0     
                    --ORDER BY AirPriority,Citycode,CityName ASC     
                    SELECT   AirportName,
                             CityName,
                             StateCode,
                             CountryCode,
                             AirportCode,
                             AirPriority,
                             CountryName
                    FROM     @tblAirport
                    ORDER BY AirPriority, CountryPriority, AirportCode ASC;
                END
            ELSE
                BEGIN
                    INSERT INTO @tblAirport
                    SELECT   AirportName,
                             CityName,
                             StateCode,
                             CountryCode,
                             AirportCode,
                             AirPriority,
                             1,
                             CountryName,
                             0,
                             CountryPriority
                    FROM     AirportLookup WITH (NOLOCK)
                    WHERE    (AirportName LIKE ('%' + @prefixText + '%')
                              OR CityName LIKE ('%' + @prefixText + '%'))
                             AND AirStatus = 0
                    ORDER BY AirPriority,CountryPriority ASC;

                            WHILE CHARINDEX('  ', @prefixText, 0) > 0
                                BEGIN
                                    SET @prefixText = REPLACE(@prefixText, '  ', ' ');
                                END
                            SET @myString = @prefixText;
                            SELECT @iCount = CHARINDEX(' ', @myString, 0);
                            IF @iCount > 0
                                BEGIN
                                    SET @sCount = 1;
                                    WHILE @sCount > 0
                                        BEGIN
                                            IF (@iCount > 0)
                                                BEGIN
                                                    SELECT @spart = SUBSTRING(@myString, 0, @iCount);
                                                    SELECT @myString = SUBSTRING(@mystring, @iCount + 1, LEN(@myString) - @iCount);
                                                END
                                            ELSE
                                                BEGIN
                                                    SET @spart = @myString;
                                                    SET @myString = '';
                                                END
                                            INSERT INTO @tblAirport
                                            SELECT   AirportName,
                                                     CityName,
                                                     StateCode,
                                                     CountryCode,
                                                     AirportCode,
                                                     AirPriority,
                                                     1,
                                                     CountryName,
                                                     0,
                                                     CountryPriority
                                            FROM     AirportLookup WITH (NOLOCK)
                                            WHERE    (AirportName LIKE (CASE @sCount 
WHEN 1 THEN (@spart + ' %') ELSE ('%' + @spart + '%') 
END)
                                                      OR CityName LIKE (CASE @sCount 
WHEN 1 THEN (@spart + ' %') ELSE ('%' + @spart + '%') 
END))
                                                     AND AirStatus = 0
                                            ORDER BY AirPriority,CountryPriority ASC;
                                            SELECT @iCount = CHARINDEX(' ', @myString, 0);
                                            SET @sCount = LEN(@myString);
                                        END
                                print '1'
                    
                        END        
                        print '2'                                    

                END
                        
                    print '3'
                    DELETE FROM @tblAirport      
                                        
					INSERT INTO @tblAirport
                    SELECT   AirportName,
                             CityName,
                             StateCode,
                             CountryCode,
                             AirportCode,
                             1,
                             1,
                             CountryName,
                             cityKey,
                             2
                    FROM     Trip..CityLookup WITH (NOLOCK)
                    WHERE    CityName LIKE ('%' + @prefixText + '%')                   
                        
                    SELECT   DISTINCT AirportName,
                                      CityName,
                                      StateCode,
                                      CountryCode,
                                      AirportCode,
                                      AirPriority,
                                      CountryName,
                                      CityGroupKey,
                                      CountryPriority
                    FROM     @tblAirport
                    ORDER BY AirPriority,CountryPriority ASC;                    
                
        END
    ELSE
        BEGIN
            INSERT INTO @tblAirport
            SELECT AirportName,
                   CityName,
                   StateCode,
                   CountryCode,
                   AL.AirportCode,
                   AirPriority,
                   1,
                   CountryName,
                   ISNULL(HG.HotelGroupId, 0) HotelGroupId,
                   CountryPriority
            FROM  AirportLookup AS AL WITH (NOLOCK)
            LEFT OUTER JOIN
			[CMS].[dbo].[CustomHotelGroup] AS HG WITH (NOLOCK)
			ON AL.AirportCode = HG.AirportCode AND HG.Visible = 0 AND HG.IsOriginal=1
			WHERE  AL.AirportCode = @prefixText
				   AND Preference = 1
			ORDER BY AirPriority,CountryPriority ASC;
			
			SET @rows1 = @@ROWCOUNT  -- Set number of rows affected
			
            INSERT INTO @tblAirport
            SELECT   AirportName,
                     CityName,
                     StateCode,
                     CountryCode,
                     AL.AirportCode,
                     AirPriority,
                     2,
                     CountryName,
                     ISNULL(HG.HotelGroupId, 0) HotelGroupId,
                     CountryPriority
            FROM     AirportLookup AS AL WITH (NOLOCK)
			LEFT OUTER JOIN
			[CMS].[dbo].[CustomHotelGroup] AS HG WITH (NOLOCK)
			ON AL.AirportCode = HG.AirportCode AND HG.Visible = 0 AND HG.IsOriginal=1
			WHERE  (REPLACE(AL.AirportName, '.', '') LIKE ('%' + @prefixText + '%')
                   OR REPLACE(AL.CityName, '.', '') LIKE ('%' + @prefixText + '%'))
                   AND AirStatus = 0
                   AND Preference = 1 --AND gmt_offset IS NOT NULL       
            ORDER BY AirPriority,CountryPriority ASC;

			SET @rows1 = @rows1 + @@ROWCOUNT   -- Set number of rows affected
            
            --  IF (SELECT COUNT(*) FROM @tblAirport) = 0      
            --  BEGIN     
            --WHILE CHARINDEX('  ', @prefixText, 0) > 0    
            --BEGIN      -- SET @prefixText = REPLACE(@prefixText, '  ', ' ')    
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
                   
                    
						SELECT   AirportName,
								 CityName,
								 StateCode,
								 CountryCode,
								 AirportCode,
								 AirPriority,
								 CountryName,
								 CityGroupKey,
								 CountryPriority
						FROM     @tblAirport
						GROUP BY AirportName, CityName, StateCode, CountryCode, AirportCode, AirPriority, CountryName, CityGroupKey,CountryPriority
						ORDER BY MIN(AirOrder),AirPriority,CountryPriority;
						--END   
						INSERT INTO @tblHotelGroup
						SELECT HG.HotelGroupId,
							   HG.HotelGroupName,
							   HG.AirportCode,
							   HG.HotelGroupName + ' [' + HG.AirportCode + ']'
						FROM   @tblAirport AS TA
							   INNER JOIN
							   [CMS].[dbo].[CustomHotelGroup] AS HG WITH (NOLOCK)
							   ON TA.AirportCode = HG.AirportCode
						WHERE  HG.Visible = 1
						UNION
						SELECT HG.HotelGroupId,
							   HG.HotelGroupName,
							   HG.AirportCode,
							   HG.HotelGroupName + ' [' + HG.AirportCode + ']'
						FROM   [CMS].[dbo].[CustomHotelGroup] AS HG WITH (NOLOCK)
						WHERE  LEN(@prefixText) > 3
							   AND HG.Visible = 1
							   AND REPLACE(HG.HotelGroupName, '.', '') LIKE '%' + @prefixText + '%';
							   
						SET @rows2 = @@ROWCOUNT   -- Set number of rows affected
							   
                        SELECT * FROM @tblHotelGroup							   
                    
                IF (@rows1 = 0 AND @rows2 = 0)
                BEGIN                    
                    DELETE FROM @tblAirport               
                    DELETE FROM @tblHotelGroup
                    
					INSERT INTO @tblAirport
                    SELECT   AirportName,
                             CityName,
                             StateCode,
                             CountryCode,
                             AirportCode,
                             1,
                             1,
                             CountryName,
                             cityKey,
                             2
                    FROM     Trip..CityLookup WITH (NOLOCK)
                    WHERE    REPLACE(CityName, '.', '') LIKE ('%' + @prefixText + '%')                   
                        
                    SELECT   DISTINCT AirportName,
                                      CityName,
                                      StateCode,
                                      CountryCode,
                                      AirportCode,
                                      AirPriority,
                                      CountryName,
                                      CityGroupKey,
                                      CountryPriority
                    FROM     @tblAirport
                    ORDER BY AirPriority,CountryPriority ASC;                   
               END
                 
        END
    DELETE @tblAirport;
END
GO
