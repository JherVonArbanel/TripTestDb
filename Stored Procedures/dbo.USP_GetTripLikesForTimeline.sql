SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel	
-- Create date: 20/Apr/2015
-- Description:	It is used to get trip likes for timeline
-- Exec USP_GetTripLikesForTimeline null
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripLikesForTimeline]
	-- Add the parameters for the stored procedure here
	@StartDate Datetime = Null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    CREATE TABLE #TimeLineTripLiked            
	(                                                                                       
	  tripKey bigint NULL,            
	  TripCreatedBy bigint NULL,
	  userKey bigint NULL,
	  userFirstName varchar(100) NULL,
	  userLastName varchar(100) NULL,
	  ImageURL nvarchar(2000) NULL,
	  createdDate datetime NULL,
	  Startdate datetime NULL ,                                
	  Enddate datetime NULL ,                                
	  toCountryName varchar(1000) NULL ,                                
	  toStateCode varchar(20) NULL ,                                
	  toCityName varchar(20) NULL ,                                
	  LatestAirLineCode varchar(100) NULL ,                                                  
	  LatestHotelChainCode varchar(100) NULL ,                                                  
	  CarVendorCode varchar(10) NULL,
	  LatestCarVendorName varchar(100) NULL,
	  originAirportCode nvarchar(100) NULL,
	  privacyType int NULL,
	  EventKey bigint DEFAULT(0),
	  NoOfComments nvarchar(1000) NULL,
	  fromCityName varchar(100) NULL,
	  tripComponents varchar(100) NULL,
	  DestinationImage varchar(500) NULL,
	  HotelRating float(8) NULL,
	  CarClass varchar(50) NULL,
	  NumberOfCurrentAirStops int default(0),
	  HotelRegionName varchar(100) null,
	  originalPerPersonPriceAir float NULL,
	  originalPerPersonPriceCar float NULL,
	  originalPerPersonPriceHotel float NULL,
	  TripCreatorImageURL nvarchar(max) NULL ,
	  TripCreatorUserName varchar(100) NULL ,
	  HotelChainName varchar(max) NULL ,
	  DestinationAirportCode varchar(10) NULL
	)
	  
    IF(@StartDate IS NULL)
    BEGIN
		INSERT INTO #TimeLineTripLiked
		(
		  tripKey,            
		  TripCreatedBy,
		  userKey,
		  userFirstName,
		  userLastName,
		  ImageURL,
		  createdDate,
		  Startdate,                                
		  Enddate,                                
		  toCountryName,                                
		  toStateCode,                                
		  toCityName,                                
		  LatestAirLineCode,                                                  
		  LatestHotelChainCode,                                                  
		  CarVendorCode,
		  LatestCarVendorName,
		  originAirportCode,
		  privacyType,
		  EventKey,
		  NoOfComments,
		  fromCityName,
		  tripComponents ,
		  DestinationImage ,
		  HotelRating ,
		  CarClass ,
		  NumberOfCurrentAirStops ,
		  HotelRegionName ,
		  originalPerPersonPriceAir ,
		  originalPerPersonPriceCar ,
		  originalPerPersonPriceHotel  ,
		  TripCreatorImageURL ,
		  TripCreatorUserName ,
		  HotelChainName ,
		  DestinationAirportCode
		)    
    	SELECT T.tripKey, T.userKey As TripCreatedBy, TL.userKey,U.userFirstName,U.userLastName,Um.ImageURL,  TL.createdDate
    	,T.StartDate,T.endDate,[toCountryName],[toStateCode],[toCityName],[LatestAirLineCode],COALESCE(NULLIF(LatestHotelChainCode,''), 'DefaultHotel'),
    	[CarVendorCode],[LatestCarVendorName] , A.originAirportCode, T.privacyType
    	,EA.eventKey As EventKey,NoOfComments, fromCityName,   
     CASE                           
      WHEN t.tripComponentType = 1 THEN 'Air'                          
      WHEN t.tripComponentType = 2 THEN 'Car'                          
      WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN t.tripComponentType = 4 THEN 'Hotel'                          
      WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents    ,
     T.DestinationSmallImageURL AS  DestinationImage, TD.HotelRating, TD.CarClass, TD.NumberOfCurrentAirStops,TD.HotelRegionName,
	 COALESCE(TD.originalPerPersonPriceAir,0) , COALESCE(TD.originalPerPersonPriceCar,0) , COALESCE(TD.originalPerPersonPriceHotel,0), USM.ImageURL,
	 (USR.userFirstName + ' ' + SUBSTRING(USR.userLastName,1,1) + '.') As TripCreatorUserName, COALESCE(HC.ChainName,TD.HotelName), TD.tripTo
     
		FROM TripLike TL 
		INNER JOIN Trip T ON TL.tripKey = T.tripKey AND TL.userKey > 0 AND TL.tripLike = 1 AND T.startDate > GETDATE() AND T.isUserCreatedSavedTrip = 1
		INNER JOIN Vault..[User] U ON TL.userKey = U.userKey
		INNER JOIN Loyalty..[UserMap] UM ON U.userKey = UM.UserId 
		LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode
					  From [Vault].[dbo].[AirPreference]
					  Where UserKey > 0
					  Group By UserKey,originAirportCode) A ON A.userKey = U.userKey
		INNER JOIN Vault..[User] USR ON USR.userKey = T.userKey
		INNER JOIN Loyalty..[UserMap] USM ON USR.userKey = USM.UserId 
		INNER JOIN [Trip].[dbo].[TripDetails] TD ON TD.tripKey = T.tripKey
		LEFT OUTER JOIN AttendeeTravelDetails AD ON AD.attendeeTripKey = T.tripKey
		LEFT OUTER JOIN EventAttendees EA ON EA.eventAttendeeKey = AD.eventAttendeekey
		LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
		LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventkey
	    LEFT OUTER JOIN (
			 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
	    ) CM ON CM.tripKey = T.tripKey  		 
		WHERE  Convert(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE()) 
		Order by TL.createdDate
    END
    ELSE
    BEGIN
		INSERT INTO #TimeLineTripLiked
		(
		  tripKey,            
		  TripCreatedBy,
		  userKey,
		  userFirstName,
		  userLastName,
		  ImageURL,
		  createdDate,
		  Startdate,                                
		  Enddate,                                
		  toCountryName,                                
		  toStateCode,                                
		  toCityName,                                
		  LatestAirLineCode,                                                  
		  LatestHotelChainCode,                                                  
		  CarVendorCode,
		  LatestCarVendorName,
		  originAirportCode,
		  privacyType,
		  EventKey,
		  NoOfComments,
		  fromCityName,
		  tripComponents  ,
		  DestinationImage ,
		  HotelRating ,
		  CarClass ,
		  NumberOfCurrentAirStops ,
		  HotelRegionName ,
		  originalPerPersonPriceAir ,
		  originalPerPersonPriceCar ,
		  originalPerPersonPriceHotel ,
		  TripCreatorImageURL ,
		  TripCreatorUserName ,
		  HotelChainName ,
		  DestinationAirportCode
		)        
		SELECT T.tripKey, T.userKey TripCreatedBy, TL.userKey,U.userFirstName,U.userLastName,Um.ImageURL,  TL.createdDate
		,T.StartDate,T.endDate,[toCountryName],[toStateCode],[toCityName],[LatestAirLineCode],COALESCE(NULLIF(LatestHotelChainCode,''), 'DefaultHotel'),
		[CarVendorCode],[LatestCarVendorName], A.originAirportCode, T.privacyType
    	,EA.eventKey As EventKey,NoOfComments, fromCityName,       
     CASE                           
      WHEN t.tripComponentType = 1 THEN 'Air'                          
      WHEN t.tripComponentType = 2 THEN 'Car'                          
      WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN t.tripComponentType = 4 THEN 'Hotel'                          
      WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents ,
     T.DestinationSmallImageURL AS  DestinationImage, TD.HotelRating, TD.CarClass, TD.NumberOfCurrentAirStops,TD.HotelRegionName,
	 COALESCE(TD.originalPerPersonPriceAir,0) , COALESCE(TD.originalPerPersonPriceCar,0) , COALESCE(TD.originalPerPersonPriceHotel,0), USM.ImageURL,
	 (USR.userFirstName + ' ' + SUBSTRING(USR.userLastName,1,1) + '.') As TripCreatorUserName, COALESCE(HC.ChainName,TD.HotelName), TD.tripTo
     
		FROM TripLike TL 
		INNER JOIN Trip T ON TL.tripKey = T.tripKey AND TL.userKey > 0 AND TL.tripLike = 1 AND T.startDate > GETDATE() AND T.isUserCreatedSavedTrip = 1
		AND TL.createdDate > @StartDate
		INNER JOIN Vault..[User] U ON TL.userKey = U.userKey
		INNER JOIN Loyalty..[UserMap] UM ON U.userKey = UM.UserId
	    LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode
					  From [Vault].[dbo].[AirPreference]
					  Where UserKey > 0
					  Group By UserKey,originAirportCode) A ON A.userKey = U.userKey
		INNER JOIN Vault..[User] USR ON USR.userKey = T.userKey
		INNER JOIN Loyalty..[UserMap] USM ON USR.userKey = USM.UserId 
		INNER JOIN [Trip].[dbo].[TripDetails] TD ON TD.tripKey = T.tripKey
		LEFT OUTER JOIN AttendeeTravelDetails AD ON AD.attendeeTripKey = T.tripKey 
		LEFT OUTER JOIN EventAttendees EA ON EA.eventAttendeeKey = AD.eventAttendeekey
		LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
		LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventkey
	    LEFT OUTER JOIN (
			 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
	    ) CM ON CM.tripKey = T.tripKey  		 		   
		WHERE  Convert(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE()) 
		Order by TL.createdDate
    END
    
  SELECT * FROM 
  (
    SELECT ROW_NUMBER() OVER (PARTITION BY tripKey ORDER BY tripkey,userkey DESC) AS ID, TD.* FROM #TimeLineTripLiked TD  
  )TD WHERE TD.ID = 1
  
  DROP TABLE #TimeLineTripLiked    
	
END
GO
