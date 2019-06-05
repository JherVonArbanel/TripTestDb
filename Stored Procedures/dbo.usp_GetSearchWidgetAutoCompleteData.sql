SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Keyur Sheth
-- Create date: 10th March 2014
-- Description:	This procedusre is used to fetch auto complete data when user enters 3 aplhabets in provided text area
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSearchWidgetAutoCompleteData]
	@strSearchString VARCHAR(5)
AS
BEGIN

SET NOCOUNT ON

-------------- FETCHING AIRPORTS START -----------------------------
--	SELECT TOP 100
--		AirportName,
--		CityName,
--		StateName,
--		ALF.CountryCode,
--		AirportCode,
--		AirPriority,
--		CountryName,
--		CityGroupKey,
--		CountryPriority,
--		SortOrder,
--		ALF.Latitude,
--		ALF.Longitude
--	FROM 
--		AirportLookupFast ALF WITH (NOLOCK)
--	WHERE 
--		SearchCode = @strSearchString 		
--	ORDER BY 
--		SortOrder ASC
		
-------------- FETCHING AIRPORTS END -----------------------------
		 		 
-------------- FETCHING HOTEL GROUPS START -----------------------------		 		 
--	SELECT TOP 100
--		HotelGroupId,
--		AirportCode,
--		CountryCode,
--		HotelGroupNameText,
--		Latitude,
--		Longitude,
--		FriendlyName
--	FROM	
--		CMS..HotelGroupLookupFast WITH (NOLOCK)
--	WHERE
--		searchcode = @strSearchString
-------------- FETCHING HOTEL GROUPS END -----------------------------		 		 

-------------- FETCHING CITIES START -----------------------------
--	SELECT TOP 100
--		AirportName,
--		CityName,
--		--StateCode,
--		StateName,
--		CLF.CountryCode,
--		AirportCode,
--		1,
--		CountryName,
--		CityKey,
--		1,
--		[Population],
--		'id1' AS OrderKey,
--		sortorder,
--		CLF.Latitude,
--		CLF.Longitude		
--	FROM 
--		vault..citylookup2fast2 CLF WITH (NOLOCK)
--	WHERE
--		searchcode = @strSearchString
--		AND AirportCode IS NOT NULL
--	ORDER BY		
--		 sortorder ASC,
--		 [Population] DESC
-------------- FETCHING CITIES END -----------------------------	

-------- commented on 2nd March 2015 ---------------------------------
--DECLARE @returnvalue varchar(max)
--DECLARE @returnvalue1 varchar(max)

--SELECT @returnvalue = AutoCompleteData FROM CMS..AutoCompleteAllFast WHERE SearchCode = @strSearchString


--IF ((SELECT COUNT(1) FROM CMS..HotelGroupLookupFast WHERE SearchCode = '***') > 0)	
--	BEGIN
--		DECLARE @AutoDataHo`````tel VARCHAR(MAX)
--		DECLARE @AutoDataConcatenateHotel VARCHAR(MAX)

--		SET @AutoDataConcatenateHotel = ''
--		SET @AutoDataHotel = ''

--		DECLARE @getAutoDataHotelGroup CURSOR
--		SET @getAutoDataHotelGroup = CURSOR FOR
--		SELECT ISNULL(HotelGroupNameText,'') + '|' + 'Hotel Groups' + '|' + CONVERT(VARCHAR(10),HotelGroupId) + '|' + CONVERT(VARCHAR(50), Latitude) + '|' + CONVERT(VARCHAR(50), Longitude) + '|' + ISNULL(FriendlyName,'')
--		FROM CMS..HotelGroupLookupFast
--		WHERE SearchCode = '***' AND HotelGroupNameText LIKE '%' + @strSearchString + '%'

--		OPEN @getAutoDataHotelGroup
--		FETCH NEXT
--		FROM @getAutoDataHotelGroup INTO @AutoDataHotel
--		WHILE @@FETCH_STATUS = 0
--		BEGIN

--		--PRINT @AutoData
--		SET @AutoDataConcatenateHotel += @AutoDataHotel + '||'

--		FETCH NEXT
--		FROM @getAutoDataHotelGroup INTO @AutoDataHotel
--		END

--		CLOSE @getAutoDataHotelGroup
--		DEALLOCATE @getAutoDataHotelGroup
	
--	SET @returnvalue1 = @AutoDataConcatenateHotel
		
--	END	

--SELECT ISNULL(@returnvalue,'') + ISNULL(@returnvalue1,'')

SELECT AllComponents FROM CMS..AutoCompleteAllFast WHERE SearchCode = @strSearchString


SET NOCOUNT OFF
		
END
GO
