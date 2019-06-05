SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- EXEC usp_GetMerchandiseTripFilter
CREATE PROC [dbo].[usp_GetMerchandiseTripFilter]
AS 
BEGIN 

----------------------- CITY -------------------------- \\

SELECT * FROM 
(
SELECT 'AMS' as CityCode , 'Amsterdam' as CityName
UNION
SELECT 'ANA' as CityCode , 'Anaheim' as CityName
UNION	
SELECT 'BCN' as CityCode , 'Barcelona' as CityName
UNION	
SELECT 'CSL' as CityCode , 'Cabo San Lucas' as CityName
UNION	
SELECT 'CUN' as CityCode , 'Cancun, Mexico' as CityName
UNION	
SELECT 'ORD' as CityCode , 'Chicago' as CityName
UNION	
SELECT 'FLL' as CityCode , 'Fort Lauderdale' as CityName
UNION	
SELECT 'HKG' as CityCode , 'Hong Kong' as CityName
UNION	
SELECT 'HNL' as CityCode , 'Honolulu' as CityName
UNION
SELECT 'LAS' as CityCode , 'Las Vegas' as CityName
UNION	
SELECT 'LON' as CityCode , 'London' as CityName
UNION	
SELECT 'LAX' as CityCode , 'Los Angeles' as CityName
UNION	
SELECT 'OGG' as CityCode , 'Maui' as CityName
UNION	
SELECT 'MIA' as CityCode , 'Miami' as CityName
UNION	
SELECT 'MBJ' as CityCode , 'Montego Bay, Jamaica' as CityName
UNION		
SELECT 'NYC' as CityCode , 'New York City' as CityName
UNION		
SELECT 'ORL' as CityCode , 'Orlando' as CityName
UNION		
SELECT 'PAR' as CityCode , 'Paris' as CityName
UNION		
SELECT 'PHX' as CityCode , 'Phoenix' as CityName
UNION			
SELECT 'PUJ' as CityCode , 'Punta Cana, Dominican Republic' as CityName
UNION			
SELECT 'ROM' as CityCode , 'Rome' as CityName
UNION			
SELECT 'SFO' as CityCode , 'San Francisco' as CityName
UNION			
SELECT 'SYD' as CityCode , 'Sydney, Australia' as CityName
UNION				
SELECT 'TPA' as CityCode , 'Tampa' as CityName
UNION					
SELECT 'WAS' as CityCode , 'Washington D.C.' as CityName

) as City ORDER BY City.CityName ASC 	



 ----------------------- PERIODS -------------------------- \\
	;
	WITH MonthYear_CTE (Date,MonthName,Level) as
	(
	
	select DATEADD(m,0,GETDATE()),LEFT(DATENAME(mm,DATEADD(m,0,GETDATE())),3), 1
	UNION ALL
	select DATEADD(m,1,Date),LEFT(DATENAME(mm,DATEADD(m,1,Date)),3), Level + 1

	FROM MonthYear_CTE
	WHERE Level <=11
	)
	Select 'All Months' as Periods
	UNION ALL
	SELECT MonthName + ' - ' + CAST(YEAR(Date) AS VARCHAR) as Periods FROM MonthYear_CTE


 ----------------------- THEME -------------------------- \\
	
	;
	WITH MerchandiseTripTheme_CTE (ThemeId, ThemeName) as 
	(
		
		SELECT 1, 'Trips with friends'  		
		UNION 
		SELECT 2, 'Romantic couple getaways'
		UNION
		SELECT 3, 'Active adventure vacations'
		UNION 
		SELECT 4, 'Beach vacations'
		UNION 
		SELECT 5, 'Mountain adventures'
		UNION 
		SELECT 6, 'Urban, historic and big city vacations'		
		UNION 
		SELECT 7, 'Gaming & shows'		
		UNION 
		SELECT 8, 'Trips with kids'		
		
		
	)
	SELECT 0 as ThemeId, 'All Trip Types' as ThemeName
	UNION ALL
	SELECT ThemeId, ThemeName FROM MerchandiseTripTheme_CTE
	

END
GO
