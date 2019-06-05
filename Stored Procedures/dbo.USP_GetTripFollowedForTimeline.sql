SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 15/02/2016
-- Description:	To get the alert for your trips followed by new follower.
-- Exec USP_GetTripFollowedForTimeline null
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripFollowedForTimeline]
	-- Add the parameters for the stored procedure here
	@StartDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
  CREATE TABLE #TimeLineTripFollowed            
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
  tripCreatorUserName varchar(100) NULL,
  tripCreatorImageURL nvarchar(2000) NULL,  
  tripComponents varchar(100) NULL,
  tripCreatorTripKey int NULL,
  FromAirportCode varchar(100) NULL,
  ToAirportCode varchar(100) NULL,
  LatestAirlineName varchar(100) NULL,
  AirRequestTypeName varchar(50) NULL,
  AirCabin varchar(50) NULL,
  HotelRating float(8) NULL,
  HotelName varchar(100) NULL,
  CarClass varchar(50) NULL,
  HotelChainName varchar(max) NULL,
  originalPerPersonPriceAir float NULL,
  originalPerPersonPriceCar float NULL,
  originalPerPersonPriceHotel float NULL,
  DestinationImage varchar(500) NULL,
  NumberOfCurrentAirStops int default(0),
  HotelRegionName varchar(100) null,
  FWtripComponents varchar(100) NULL,
  FWLatestAirLineCode varchar(100) NULL ,  
  FWCarVendorCode varchar(100) NULL,
  FWCarClass varchar(50) NULL,
  FWHotelRating float(8) NULL,
  FWHotelName varchar(100) NULL,
  FWHotelChainName varchar(max) NULL   ,  
  FWLatestHotelChainCode varchar(100) NULL ,
  FWLatestAirlineName varchar(100) NULL,
  FWAirRequestTypeName varchar(50) NULL,
  FWAirCabin varchar(50) NULL
  )        
    
    IF(@StartDate IS NULL)
    BEGIN
    INSERT INTO #TimeLineTripFollowed
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
	  tripCreatorUserName,
	  tripCreatorImageURL,
	  tripComponents,
	  tripCreatorTripKey ,
	  FromAirportCode,
	  ToAirportCode ,
	  LatestAirlineName ,
	  AirRequestTypeName ,
	  AirCabin,
	  HotelRating ,
	  HotelName ,
	  CarClass ,
	  HotelChainName ,
	  originalPerPersonPriceAir ,
	  originalPerPersonPriceCar ,
	  originalPerPersonPriceHotel,
	  DestinationImage,
	  NumberOfCurrentAirStops,
	  HotelRegionName ,
	  FWtripComponents ,
	  FWLatestAirLineCode  ,  
	  FWCarVendorCode ,
	  FWCarClass ,
	  FWHotelRating ,
	  FWHotelName ,
	  FWHotelChainName  ,  
	  FWLatestHotelChainCode ,
	  FWLatestAirlineName ,
	  FWAirRequestTypeName ,
	  FWAirCabin
    )
    	SELECT T.tripKey, TC.userKey TripCreatedBy, TS.userKey,U.userFirstName,U.userLastName,Um.ImageURL,  TS.createdDate
    	,T.StartDate,T.endDate,TD1.toCountryName,TD1.toStateCode,TD1.toCityName,TD1.LatestAirLineCode,COALESCE(NULLIF(TD1.LatestHotelChainCode,''), 'DefaultHotel'),TD1.CarVendorCode,TD1.LatestCarVendorName
    	, A.originAirportCode, T.privacyType
    	,EA.eventKey As EventKey,NoOfComments, TD1.fromCityName,(UC.userFirstName + ' ' + SUBSTRING(UC.userLastName,1,1) + '.') As tripCreatorUserName, UMC.ImageURL AS   TripCreatorImageURL, 
     CASE                           
      WHEN TC.tripComponentType = 1 THEN 'Air'                          
      WHEN TC.tripComponentType = 2 THEN 'Car'                          
      WHEN TC.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN TC.tripComponentType = 4 THEN 'Hotel'                          
      WHEN TC.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN TC.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN TC.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents, TC.tripKey ,
     COALESCE(TD1.fromCityName,'') + ', ' + COALESCE(TD1.fromStateCode,'') + ' [' + TD1.tripFrom + ']' AS FromAirportCode,
      COALESCE(TD1.toCityName,'') + ', ' + COALESCE(TD1.toStateCode,'') + ' [' + TD1.TripTo +']' AS ToAirportCode,
      TD1.LatestAirlineName, TD1.AirRequestTypeName, TD1.AirCabin, TD1.HotelRating, TD1.HotelName, TD1.CarClass,COALESCE(HC.ChainName,TD1.HotelName),
      COALESCE(TD.originalPerPersonPriceAir,0) , COALESCE(TD.originalPerPersonPriceCar,0) , COALESCE(TD.originalPerPersonPriceHotel,0), EV.eventImageURL AS DestinationImage,TD.NumberOfCurrentAirStops, TD.HotelRegionName,
      CASE                           
      WHEN T.tripComponentType = 1 THEN 'Air'                          
      WHEN T.tripComponentType = 2 THEN 'Car'                          
      WHEN T.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN T.tripComponentType = 4 THEN 'Hotel'                          
      WHEN T.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN T.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN T.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS FWtripComponents, TD.LatestAirLineCode AS FWLatestAirLineCode, TD.CarVendorCode AS FWCarVendorCode, 
     TD.CarClass AS FWCarClass, TD.HotelRating AS FWHotelRating, TD.HotelName AS FWHotelName, COALESCE(HC.ChainName,TD.HotelName) AS FWHotelChainName,
     COALESCE(NULLIF(TD.LatestHotelChainCode,''),'DefaultHotel') AS FWLatestHotelChainCode, TD.LatestAirlineName, TD.AirRequestTypeName, TD.AirCabin
     
		FROM TripSaved TS -- 
		INNER JOIN Trip T ON TS.tripSavedKey = T.tripSavedKey AND TS.userKey > 0  AND TS.parentSaveTripKey is not null AND T.endDate > GETDATE() AND T.isUserCreatedSavedTrip = 1
		INNER JOIN Trip TC ON TC.tripSavedKey = TS.parentSaveTripKey AND T.tripKey <> TC.tripKey 
		INNER JOIN Vault..[User] U ON TS.userKey = U.userKey
		INNER JOIN Loyalty..[UserMap] UM ON U.userKey = UM.UserId 
		INNER JOIN Vault..[User] UC ON TC.userKey = UC.userKey
		INNER JOIN Loyalty..[UserMap] UMC ON UC.userKey = UMC.UserId 		
		LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode
					  From [Vault].[dbo].[AirPreference]
					  Where UserKey > 0
					  Group By UserKey,originAirportCode) A ON A.userKey = U.userKey
		INNER JOIN [Trip].[dbo].[TripDetails] TD ON TD.tripKey = T.tripKey
		INNER JOIN [Trip].[dbo].[TripDetails] TD1 ON TD1.tripKey = TC.tripKey
		LEFT OUTER JOIN AttendeeTravelDetails AD ON AD.attendeeTripKey = T.tripKey
		LEFT OUTER JOIN EventAttendees EA ON EA.eventAttendeeKey = AD.eventAttendeekey
		LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
		LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventkey
	    LEFT OUTER JOIN (
			 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
	    ) CM ON CM.tripKey = T.tripKey  		 
		WHERE TS.createdDate IS NOT NULL --AND Convert(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE()) 
		Order by TS.createdDate
    END
    ELSE
    BEGIN
    INSERT INTO #TimeLineTripFollowed
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
	  tripCreatorUserName,
	  tripCreatorImageURL,	  
	  tripComponents,
	  tripCreatorTripKey   ,
	  FromAirportCode,
	  ToAirportCode ,
	  LatestAirlineName ,
	  AirRequestTypeName ,
	  AirCabin,
	  HotelRating ,
	  HotelName,
	  CarClass ,
	  HotelChainName ,
	  originalPerPersonPriceAir ,
	  originalPerPersonPriceCar ,
	  originalPerPersonPriceHotel,
	  DestinationImage,
	  NumberOfCurrentAirStops,
	  HotelRegionName ,
	  FWtripComponents ,
	  FWLatestAirLineCode  ,  
	  FWCarVendorCode ,
	  FWCarClass ,
	  FWHotelRating ,
	  FWHotelName ,
	  FWHotelChainName  ,  
	  FWLatestHotelChainCode ,
	  FWLatestAirlineName ,
	  FWAirRequestTypeName ,
	  FWAirCabin
    )    
		SELECT T.tripKey, TC.userKey TripCreatedBy, TS.userKey,U.userFirstName,U.userLastName,Um.ImageURL,  TS.createdDate
		,T.StartDate,T.endDate,TD1.toCountryName,TD1.toStateCode,TD1.toCityName,TD1.LatestAirLineCode,COALESCE(NULLIF(TD1.LatestHotelChainCode,''), 'DefaultHotel'),TD1.CarVendorCode,TD1.LatestCarVendorName
		, A.originAirportCode, T.privacyType
    	,EA.eventKey As EventKey,NoOfComments, TD1.fromCityName,(UC.userFirstName + ' ' + SUBSTRING(UC.userLastName,1,1) + '.') As tripCreatorUserName, UMC.ImageURL AS   TripCreatorImageURL,        
     CASE                           
      WHEN TC.tripComponentType = 1 THEN 'Air'                          
      WHEN TC.tripComponentType = 2 THEN 'Car'                          
      WHEN TC.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN TC.tripComponentType = 4 THEN 'Hotel'                          
      WHEN TC.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN TC.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN TC.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents, TC.tripKey ,
     COALESCE(TD1.fromCityName,'') + ', ' + COALESCE(TD1.fromStateCode,'') + ' [' + TD.tripFrom + ']' AS FromAirportCode,
      COALESCE(TD1.toCityName,'') + ', ' + COALESCE(TD1.toStateCode,'') + ' [' + TD.TripTo +']' AS ToAirportCode,
      TD1.LatestAirlineName, TD1.AirRequestTypeName, TD1.AirCabin, TD1.HotelRating, TD1.HotelName, TD1.CarClass,COALESCE(HC.ChainName,TD1.HotelName),
      COALESCE(TD.originalPerPersonPriceAir,0) , COALESCE(TD.originalPerPersonPriceCar,0) , COALESCE(TD.originalPerPersonPriceHotel,0), EV.eventImageURL AS DestinationImage,TD.NumberOfCurrentAirStops, TD.HotelRegionName,
      CASE                           
      WHEN T.tripComponentType = 1 THEN 'Air'                          
      WHEN T.tripComponentType = 2 THEN 'Car'                          
      WHEN T.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN T.tripComponentType = 4 THEN 'Hotel'                          
      WHEN T.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN T.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN T.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS FWtripComponents, TD.LatestAirLineCode AS FWLatestAirLineCode, TD.CarVendorCode AS FWCarVendorCode, 
     TD.CarClass AS FWCarClass, TD.HotelRating AS FWHotelRating, TD.HotelName AS FWHotelName, COALESCE(HC.ChainName,TD.HotelName) AS FWHotelChainName,
     COALESCE(NULLIF(TD.LatestHotelChainCode,''),'DefaultHotel') AS FWLatestHotelChainCode, TD.LatestAirlineName, TD.AirRequestTypeName, TD.AirCabin
     
		FROM TripSaved TS 
		INNER JOIN Trip T ON TS.tripSavedKey = T.tripSavedKey AND TS.userKey > 0  AND TS.parentSaveTripKey is not null AND  T.endDate > GETDATE() AND TS.createdDate > @StartDate AND T.isUserCreatedSavedTrip = 1
		INNER JOIN Trip TC ON TC.tripSavedKey = TS.parentSaveTripKey AND T.tripKey <> TC.tripKey 
		INNER JOIN Vault..[User] U ON TS.userKey = U.userKey
		INNER JOIN Loyalty..[UserMap] UM ON U.userKey = UM.UserId
		INNER JOIN Vault..[User] UC ON TC.userKey = UC.userKey
		INNER JOIN Loyalty..[UserMap] UMC ON UC.userKey = UMC.UserId 				
	    LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode
					  From [Vault].[dbo].[AirPreference]
					  Where UserKey > 0
					  Group By UserKey,originAirportCode) A ON A.userKey = U.userKey
		INNER JOIN [Trip].[dbo].[TripDetails] TD ON TD.tripKey = T.tripKey
		INNER JOIN [Trip].[dbo].[TripDetails] TD1 ON TD1.tripKey = TC.tripKey
		LEFT OUTER JOIN AttendeeTravelDetails AD ON AD.attendeeTripKey = T.tripKey 
		LEFT OUTER JOIN EventAttendees EA ON EA.eventAttendeeKey = AD.eventAttendeekey
		LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
		LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventkey
	    LEFT OUTER JOIN (
			 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
	    ) CM ON CM.tripKey = T.tripKey  		 		   
		WHERE TS.createdDate IS NOT NULL AND Convert(Date,TD.lastUpdatedDate)= Convert(Date,GETDATE()) 
		Order by TS.createdDate
    END
    
    
  SELECT * FROM 
  (
    SELECT ROW_NUMBER() OVER (PARTITION BY tripKey ORDER BY tripkey,userkey DESC) AS ID, TD.* FROM #TimeLineTripFollowed TD  
  )TD WHERE TD.ID = 1
  
  DROP TABLE #TimeLineTripFollowed
    
	
END
GO
