SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- EXEC usp_GetBXRules 'LGA', 'BOS', 70
CREATE PROC [dbo].[usp_GetBXRules]
(
	@FromAirportCode VARCHAR(3),
	@ToAirportCode VARCHAR(3),	
	@SiteKey INT

)
AS
BEGIN 

	SET NOCOUNT ON;

	DECLARE @FromCountryCode VARCHAR(2),
			@ToCountryCode VARCHAR(2),
			@FromStateCode VARCHAR(2),
			@ToStateCode VARCHAR(2),
			@FromCount INT,
			@ToCount INT,
			@IsAvailable BIT

	DECLARE @FromRegionIds TABLE
	(
		FromRegionId INT		
	)

	DECLARE @ToRegionIds TABLE
	(
		ToRegionId INT		
	)

	SET @IsAvailable = 1
	

	--IF ((LTRIM(RTRIM(LOWER(@FromAirportCode))) = 'jfk' OR LTRIM(RTRIM(LOWER(@FromAirportCode))) = 'sfo' OR LTRIM(RTRIM(LOWER(@FromAirportCode))) = 'lax') AND (LTRIM(RTRIM(LOWER(@ToAirportCode))) = 'jfk' OR LTRIM(RTRIM(LOWER(@ToAirportCode))) = 'sfo' OR LTRIM(RTRIM(LOWER(@ToAirportCode))) = 'lax'))
	--BEGIN 

	--	INSERT INTO @FromRegionIds VALUES (3) 
	--	INSERT INTO @ToRegionIds VALUES (3) 
	--END


	-- SELECT @FromCount = COUNT(1) FROM @FromRegionIds
	-- SELECT @ToCount = COUNT(1) FROM @ToRegionIds



	SELECT @FromCountryCode = CountryCode,
		   @FromStateCode = StateCode  
	FROM AirportLookup WITH(NOLOCK)
	WHERE AirportCode = @FromAirportCode

	SELECT 
			@ToCountryCode = CountryCode,
			@ToStateCode = StateCode  
	FROM AirportLookup WITH(NOLOCK)
	WHERE AirportCode = @ToAirportCode

	--SELECT @FromCount, @ToCount
	--SELECT @FromStateCode, @ToStateCode

	IF (@FromCountryCode = 'CA' AND @ToCountryCode = 'CA')
	BEGIN 		
		SET @IsAvailable = 0
	END 

	IF (@FromCountryCode = 'MX' AND @ToCountryCode = 'MX')
	BEGIN 		
		SET @IsAvailable = 0
	END 



	-- SAMIR Only for Canada and Mexico (Within US Rule) there should not be any AA rules coming for travelling withing canada and mexico. It should be always US to Canada OR US to Mexico.  
	IF (@IsAvailable = 1)
	BEGIN  
		--IF (@FromCount = 0 OR @ToCount = 0)
		BEGIN 
			INSERT INTO @FromRegionIds
			SELECT RegionId FROM RegionCountryMapping WITH(NOLOCK)
			WHERE CountryCode = @FromCountryCode
			AND ISNULL(StateCode,'') = CASE WHEN LTRIM(RTRIM(LOWER(@FromStateCode))) = 'hi' THEN 'HI' ELSE '' END

			INSERT INTO @ToRegionIds
			SELECT RegionId FROM RegionCountryMapping WITH(NOLOCK)		
			WHERE CountryCode = @ToCountryCode
			AND ISNULL(StateCode,'') = CASE WHEN LTRIM(RTRIM(LOWER(@ToStateCode))) = 'hi' THEN 'HI' ELSE '' END

			IF ((LTRIM(RTRIM(LOWER(@FromAirportCode))) = 'lga' OR LTRIM(RTRIM(LOWER(@FromAirportCode))) = 'bos' OR LTRIM(RTRIM(LOWER(@FromAirportCode))) = 'dca') AND (LTRIM(RTRIM(LOWER(@ToAirportCode))) = 'lga' OR LTRIM(RTRIM(LOWER(@ToAirportCode))) = 'bos' OR LTRIM(RTRIM(LOWER(@ToAirportCode))) = 'dca'))
			BEGIN 

				INSERT INTO @FromRegionIds VALUES (1) 
				INSERT INTO @ToRegionIds VALUES (1) 
			END


		END
	END
	--SELECT @FromCountryCode, @ToCountryCode

	--SELECT * FROM @FromRegionIds
	--SELECT * FROM @ToRegionIds

	SELECT 
		FromRegionId, 
		ToRegionId, 
		--RegionName, 
		RuleData 
	FROM BXRules WITH(NOLOCK)
		/*
	INNER JOIN RegionLookup ON 
		(BXRules.FromRegionId = RegionLookup.Id 
			OR
		BXRules.ToRegionId = RegionLookup.Id )
	*/
	WHERE FromRegionId IN (SELECT DISTINCT FromRegionId FROM @FromRegionIds)
	AND 
		ToRegionId IN (SELECT DISTINCT  ToRegionId FROM @ToRegionIds)
/*
	AND
		siteKey = @SiteKey
*/	
	--SELECT * FROM BXRules

END
GO
