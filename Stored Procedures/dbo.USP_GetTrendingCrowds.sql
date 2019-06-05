SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <17-Feb-2016>
-- Description:	<Get city wise trip trending list>
-- Exec USP_GetTrendingCrowds
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTrendingCrowds] 
	 @IsHotelSchedular bit = 0
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @tbl TABLE (ImageURL VARCHAR(5000), TripTo VARCHAR(50), CrowdCount INT,CityName VARCHAR(150),AverageSavingTotal FLOAT DEFAULT(0))

	DECLARE @tblFinal TABLE (ImageURL VARCHAR(5000), TripTo VARCHAR(50), CrowdCount INT,CityName VARCHAR(150),AverageSavingTotal FLOAT DEFAULT(0))


	INSERT INTO @tbl(ImageURL,TripTo, CrowdCount,AverageSavingTotal)
		SELECT 
			--TRIP.dbo.getImageURLFromCityCode(TD.tripTo)
			T.DestinationSmallImageURL
			, TD.tripTo,COUNT(TD.tripTo),
				SUM
			(
				CASE WHEN ISNULL(latestDealAirSavingsPerPerson,0) < 0 THEN 0 ELSE ISNULL(latestDealAirSavingsPerPerson,0) END
				+ CASE WHEN ISNULL(latestDealCarSavingsPerPerson,0) < 0 THEN 0 ELSE ISNULL(latestDealCarSavingsPerPerson,0) END
				+ CASE WHEN ISNULL(latestDealHotelSavingsPerPerson,0) < 0 THEN 0 ELSE ISNULL(latestDealHotelSavingsPerPerson,0) END
			) 
		FROM TRIP..TripDetails TD WITH (NOLOCK)
		INNER JOIN Trip..Trip T WITH (NOLOCK) ON T.tripKey = TD.tripKey 
		WHERE 
		T.tripStatusKey <> 17   
		AND TD.tripTo IS NOT NULL
		AND TD.tripStartDate > DATEADD(D,2, GetDate())
		AND T.PrivacyType <>2          
		AND T.IsWatching = 1 AND T.isUserCreatedSavedTrip =1 
		AND 1  = (Select Top 1 1 From TripHashTagMapping TH Where TH.TripKey = T.tripKey )
		And 0 = (Select
					CASE             
						WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
						WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
						WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
						WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
						WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
					        
						WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'         
					    
						WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
						ELSE 0     End
					FROM Trip t1 inner join TripDetails td on t1.tripKey = td.tripKey  Where t1.tripKey = T.tripKey)
		GROUP BY TD.tripTo,T.DestinationSmallImageURL ORDER BY COUNT(TD.tripTo) DESC

	UPDATE t SET CityName = AL.CityName 
	FROM @tbl t 
		INNER JOIN trip..AirportLookup AL WITH (NOLOCK) ON t.TripTo = AL.AirportCode 
		
	--UPDATE t SET CityName = AL.FriendlyName 
	--FROM @tbl t 
	--	INNER JOIN CMS..CustomHotelGroup AL WITH (NOLOCK) ON t.TripTo = AL.AirportCode AND AL.Visible=0 
	--select * from @tbl
	--SELECT Distinct ',' +  tbl.TripTo FROM @tbl tbl
	--select STUFF((SELECT Distinct ',' +  tbl.TripTo FROM @tbl tbl WHERE tbl.CityName = t.CityName FOR XML PATH ('')), 1, 1, '')  FROM @tbl t
	
	INSERT INTO @tblFinal(ImageURL,TripTo, CrowdCount,CityName,AverageSavingTotal)	
	SELECT MAX(t.ImageURL) AS ImageURL
		, STUFF((SELECT Distinct ',' +  tbl.TripTo FROM @tbl tbl WHERE tbl.CityName = t.CityName FOR XML PATH ('')), 1, 1, '') AS TripTo
		, SUM(t.CrowdCount) AS CrowdCount,CityName,SUM(t.AverageSavingTotal) /  ISNULL(SUM(t.CrowdCount),1) as AverageSavingTotal
	FROM @tbl t
	GROUP BY t.CityName ORDER BY SUM(t.CrowdCount) DESC
	
	
	IF @IsHotelSchedular = 1
	BEGIN
	
	SELECT CASE 
			WHEN CityName='New York' THEN '/Content/Images/Destination/12/statue-of-liberty-vertical.jpg'
			WHEN CityName='London' THEN '/Content/Images/Destination/35/Big-Ben-Houses-Parliament-London-England-Great-Britain.jpg'
			WHEN CityName='Washington' THEN '/Content/Images/Destination/17/91632041_capitol_lake300.jpg'
			WHEN CityName='Paris' THEN '/Content/Images/Destination/28/glowing-sun-paris.jpg'			
			ELSE ImageURL
		 END AS	ImageURL,
		TripTo, 
		CrowdCount,
		CityName,
		AverageSavingTotal
	FROM @tblFinal
	where TripTo in (select tbl.tripto from @tbl tbl where tbl.TripTo in (select hc.Origin from Trip..HotelCacheData hc where hc.Origin not in (tbl.TripTo) ))
	END
	
	ELSE
	BEGIN
	--AS DISCUSSED WITH ZARIR TEMPORARY REPLACE THIS DESTINATION URL FOR SPECIFIC DESTINATION CODE.
	SELECT CASE 
			WHEN CityName='New York' THEN '/Content/Images/Destination/12/statue-of-liberty-vertical.jpg'
			WHEN CityName='London' THEN '/Content/Images/Destination/35/Big-Ben-Houses-Parliament-London-England-Great-Britain.jpg'
			WHEN CityName='Washington' THEN '/Content/Images/Destination/17/91632041_capitol_lake300.jpg'
			WHEN CityName='Paris' THEN '/Content/Images/Destination/28/glowing-sun-paris.jpg'			
			ELSE ImageURL
		 END AS	ImageURL,
		TripTo, 
		CrowdCount,
		CityName,
		AverageSavingTotal
	FROM @tblFinal
	END
END
GO
