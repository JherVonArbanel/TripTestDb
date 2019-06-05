SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 20/Apr/2015
-- Description:	It is used to get attendee datas for timelien
-- EXEC USP_GetAttendeesForTimeline null
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAttendeesForTimeline]
	-- Add the parameters for the stored procedure here
	@StartDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
	CREATE TABLE #TmpAttendeeTripDetailsHost
    (  
       [userKey]  [bigint] NOT NULL,  
       [eventKey] [int] NOT NULL,
       [tripKey]  [bigint] NOT NULL 
	) 
	
	CREATE TABLE #TimeLineTripAttendees            
 (                                                           
  CreatedBy bigint NULL,                                                              
  eventKey bigint NULL,                                                                  
  eventName varchar(500) NULL ,  
  userKey bigint NULL,
  attendeeStatusKey int NULL,
  eventStartDate datetime NULL,
  eventEndDate datetime NULL,
  tripkey bigint NULL,
  userFirstName varchar(100) NULL,
  userLastName varchar(100) NULL,
  ImageURL nvarchar(2000) NULL,
  creationDate datetime NULL,
  eventDestination varchar(20) NULL ,        
  toCountryCode varchar(50) NULL ,                                                            
  toCountryName nvarchar(500) NULL ,                                 
  toStateCode varchar(20) NULL ,                                
  toCityName varchar(20) NULL ,    
  tripEndDate datetime NULL,                 
  LatestAirLineCode varchar(100) NULL ,                                                  
  LatestHotelChainCode varchar(100) NULL ,                                                  
  CarVendorCode varchar(10) NULL,
  LatestCarVendorName varchar(100) NULL,
  privacyType int NULL, 
  NoOfComments nvarchar(1000) NULL,
  fromCityName varchar(100) NULL,
  tripComponents varchar(100) NULL,
  FromAirportCode varchar(100) NULL,
  ToAirportCode varchar(100) NULL,
  LatestAirlineName varchar(100) NULL,
  AirRequestTypeName varchar(50) NULL,
  AirCabin varchar(50) NULL,
  HotelRating float(8) NULL,
  HotelName varchar(100) NULL,
  CarClass varchar(50) NULL,
  HotelChainName varchar(max) NULL,
  AttendeeTripkey bigint NULL,
  originalPerPersonPriceAir float NULL,
  originalPerPersonPriceCar float NULL,
  originalPerPersonPriceHotel float NULL,
  DestinationImage varchar(500) NULL,
  TripCreatorUserName varchar(100) NULL,
  TripCreatorImageURL nvarchar(2000) NULL,
  NumberOfCurrentAirStops int default(0),
  HotelRegionName varchar(100) null   
 )        
	
	INSERT INTO #TmpAttendeeTripDetailsHost
	SELECT EA.userKey,EV.eventKey, ATD.attendeeTripKey FROM EventAttendees EA
	INNER JOIN [Trip].[dbo].[Events] EV ON EV.eventKey = EA.eventKey AND EA.isDeleted = 0 
     AND EV.eventStartDate > GETDATE() AND EA.isHost = 1
    INNER JOIN [Trip].[dbo].[AttendeeTravelDetails] ATD ON ATD.eventAttendeekey = EA.eventAttendeeKey
    
    IF(@StartDate IS NULL)
    BEGIN
    INSERT INTO #TimeLineTripAttendees
    (
	  CreatedBy,                                                      
	  eventKey,                                                                  
	  eventName ,  
	  userKey,
	  attendeeStatusKey,
	  eventStartDate,
	  eventEndDate,
	  tripKey,
	  userFirstName,
	  userLastName ,
	  ImageURL ,
	  creationDate,
	  eventDestination,        
	  toCountryCode,                                                            
	  toCountryName,                                 
	  toStateCode,                                
	  toCityName,    
	  tripEndDate,                 
	  LatestAirLineCode,                                                  
	  LatestHotelChainCode,                                                  
	  CarVendorCode,
	  LatestCarVendorName,
	  privacyType, 
	  NoOfComments,
	  fromCityName,
	  tripComponents,
	  FromAirportCode,
	  ToAirportCode ,
	  LatestAirlineName ,
	  AirRequestTypeName ,
	  AirCabin,
	  HotelRating ,
	  HotelName ,
	  CarClass ,
	  HotelChainName,
	  AttendeeTripkey,
	  originalPerPersonPriceAir ,
	  originalPerPersonPriceCar ,
	  originalPerPersonPriceHotel,
	  DestinationImage,
	  tripCreatorUserName,
	  tripCreatorImageURL,
	  NumberOfCurrentAirStops,
	  HotelRegionName
    )
    SELECT E.userKey AS CreatedBy, EA.[eventKey],E.eventName,EA.[userKey],EA.attendeeStatusKey,E.eventStartDate,E.eventEndDate,
    --(CASE WHEN ATD.attendeeTripKey IS NULL THEN TATD.tripKey ELSE ATD.attendeeTripKey END) As TripKey,
    TATD.tripKey As TripKey,
    U.userFirstName,U.userLastName,UM.ImageURL, [attendeeActionDate] AS creationDate, E.eventDestination
    ,[toCountryCode],[toCountryName],[toStateCode],[toCityName],[tripEndDate],[LatestAirLineCode],COALESCE([LatestHotelChainCode],'DefaultHotel'),[CarVendorCode],[LatestCarVendorName]
     ,T.privacyType, NoOfComments, fromCityName,       
     CASE                           
      WHEN t.tripComponentType = 1 THEN 'Air'                          
      WHEN t.tripComponentType = 2 THEN 'Car'                          
      WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN t.tripComponentType = 4 THEN 'Hotel'                          
      WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents  ,
     [fromCityName] + ', ' + [fromStateCode] + ' [' + TD.tripFrom + ']' AS FromAirportCode,
      [toCityName] + ', ' + [toStateCode] + ' [' + TD.TripTo +']' AS ToAirportCode,
      TD.LatestAirlineName, TD.AirRequestTypeName, TD.AirCabin, TD.HotelRating, TD.HotelName, TD.CarClass,COALESCE(HC.ChainName,TD.HotelName), TD.tripKey as attendeeTripKey,
      COALESCE(TD.originalPerPersonPriceAir,0) , COALESCE(TD.originalPerPersonPriceCar,0) , COALESCE(TD.originalPerPersonPriceHotel,0), E.eventImageURL AS DestinationImage,
      (TCU.userFirstName + ' ' + SUBSTRING(TCU.userLastName,1,1) + '.') As TripCreatorUserName,TCUM.ImageURL as  TripCreatorImageURL,TD.NumberOfCurrentAirStops, TD.HotelRegionName
     
    FROM [Trip].[dbo].[EventAttendees] EA 
    INNER JOIN [Events] E ON E.eventKey = EA.eventKey AND EA.isDeleted = 0 
     AND E.eventStartDate > GETDATE() 
     AND EA.attendeeStatusKey = 3 -- uncommented this line as alert getting generated even if attendde say maybe 
    AND EA.isHost = 0
    LEFT OUTER JOIN [AttendeeTravelDetails] ATD ON EA.eventAttendeeKey = ATD.eventAttendeekey
    LEFT OUTER JOIN #TmpAttendeeTripDetailsHost TATD ON TATD.eventKey = EA.eventKey
    LEFT OUTER JOIN [Trip].[dbo].[TripDetails] TD ON TD.tripKey =
    CASE 
      WHEN TATD.tripKey IS NULL THEN  ATD.attendeeTripKey ELSE TATD.tripKey END
    LEFT OUTER JOIN [Trip].[dbo].[Trip] T ON T.tripKey = TD.tripKey AND T.isUserCreatedSavedTrip = 1
    INNER JOIN Vault..[USER] U ON U.userKey = EA.userKey
    INNER JOIN Loyalty..UserMap UM ON U.userKey = UM.UserId
    INNER JOIN Vault..[USER] TCU ON TCU.userKey = E.userKey  -- host information/TripCreator
    INNER JOIN Loyalty..UserMap TCUM ON TCU.userKey = TCUM.UserId  -- host information /TripCreator 
    LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
	LEFT OUTER JOIN (
		 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
	) CM ON CM.tripKey = T.tripKey    
	
    ORDER BY [attendeeActionDate]
    
    
    END
    ELSE
    BEGIN
    INSERT INTO #TimeLineTripAttendees
    (
	  CreatedBy,                                                      
	  eventKey,                                                                  
	  eventName ,  
	  userKey,
	  attendeeStatusKey,
	  eventStartDate,
	  eventEndDate,
	  tripkey,
	  userFirstName,
	  userLastName ,
	  ImageURL ,
	  creationDate,
	  eventDestination,        
	  toCountryCode,                                                            
	  toCountryName,                                 
	  toStateCode,                                
	  toCityName,    
	  tripEndDate,                 
	  LatestAirLineCode,                                                  
	  LatestHotelChainCode,                                                  
	  CarVendorCode,
	  LatestCarVendorName,
	  privacyType, 
	  NoOfComments,
	  fromCityName,
	  tripComponents  ,
	  FromAirportCode,
	  ToAirportCode ,
	  LatestAirlineName ,
	  AirRequestTypeName ,
	  AirCabin,
	  HotelRating ,
	  HotelName  ,
	  CarClass,
	  HotelChainName,
	  AttendeeTripkey,
	  originalPerPersonPriceAir ,
	  originalPerPersonPriceCar ,
	  originalPerPersonPriceHotel,
	  DestinationImage,
	  TripCreatorUserName,
	  TripCreatorImageURL,
	  NumberOfCurrentAirStops,
	  HotelRegionName
    )
    SELECT  E.userKey AS CreatedBy,EA.[eventKey],E.eventName,EA.[userKey],EA.attendeeStatusKey,E.eventStartDate,E.eventEndDate,
    --(CASE WHEN ATD.attendeeTripKey IS NULL THEN TATD.tripKey ELSE ATD.attendeeTripKey END) As TripKey,
     TATD.tripKey As TripKey,
    U.userFirstName,U.userLastName,UM.ImageURL, [attendeeActionDate] AS creationDate,E.eventDestination
    ,[toCountryCode],[toCountryName],[toStateCode],[toCityName],[tripEndDate],[LatestAirLineCode],COALESCE([LatestHotelChainCode],'DefaultHotel'),[CarVendorCode],[LatestCarVendorName]
    ,T.privacyType,NoOfComments, fromCityName,       
     CASE                           
      WHEN t.tripComponentType = 1 THEN 'Air'                          
      WHEN t.tripComponentType = 2 THEN 'Car'                          
      WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
      WHEN t.tripComponentType = 4 THEN 'Hotel'                          
      WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
      WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
      WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
     END AS tripComponents    ,
     [fromCityName] + ', ' + [fromStateCode] + ' [' + TD.tripFrom + ']' AS FromAirportCode,
      [toCityName] + ', ' + [toStateCode] + ' [' + TD.TripTo +']' AS ToAirportCode,
      TD.LatestAirlineName, TD.AirRequestTypeName, TD.AirCabin, TD.HotelRating, TD.HotelName, TD.CarClass,COALESCE(HC.ChainName,TD.HotelName), TD.tripKey as attendeeTripKey,
      COALESCE(TD.originalPerPersonPriceAir,0) , COALESCE(TD.originalPerPersonPriceCar,0) , COALESCE(TD.originalPerPersonPriceHotel,0), E.eventImageURL AS DestinationImage,
      (TCU.userFirstName + ' ' + SUBSTRING(TCU.userLastName,1,1) + '.') As TripCreatorUserName,TCUM.ImageURL as  TripCreatorImageURL, TD.NumberOfCurrentAirStops, TD.HotelRegionName
     
    FROM [Trip].[dbo].[EventAttendees] EA 
    INNER JOIN [Events] E ON E.eventKey = EA.eventKey AND EA.isDeleted = 0 
    AND E.eventStartDate > GETDATE() 
    AND EA.attendeeStatusKey = 3 -- uncommented this line as alert getting generated even if attendde say maybe
    --AND EA.isHost = 0 
    AND EA.attendeeActionDate > @StartDate
    LEFT OUTER JOIN [AttendeeTravelDetails] ATD ON EA.eventAttendeeKey = ATD.eventAttendeekey
    LEFT OUTER JOIN #TmpAttendeeTripDetailsHost TATD ON TATD.eventKey = EA.eventKey   
    LEFT OUTER JOIN [Trip].[dbo].[TripDetails] TD ON TD.tripKey =
    CASE 
      WHEN TATD.tripKey IS NULL THEN  ATD.attendeeTripKey ELSE TATD.tripKey END
    LEFT OUTER JOIN [Trip].[dbo].[Trip] T ON T.tripKey = TD.tripKey AND T.isUserCreatedSavedTrip = 1
    INNER JOIN Vault..[USER] U ON U.userKey = EA.userKey
    INNER JOIN Loyalty..UserMap UM ON U.userKey = UM.UserId
    INNER JOIN Vault..[USER] TCU ON TCU.userKey = E.userKey  -- host information/TripCreator
    INNER JOIN Loyalty..UserMap TCUM ON TCU.userKey = TCUM.UserId  -- host information /TripCreator  
    LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TD.LatestHotelChainCode
	LEFT OUTER JOIN (
		 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
	) CM ON CM.tripKey = T.tripKey  
    
    ORDER BY [attendeeActionDate]
    END
    
   SELECT * FROM 
  (
    SELECT ROW_NUMBER() OVER (PARTITION BY tripKey ORDER BY tripkey,userkey DESC) AS ID, TD.* FROM #TimeLineTripAttendees TD  
  )TD --WHERE TD.ID = 1  If two poeple joined the trip event but here query is picking up only 1 people from event and hence 2 people not considered (by Vivek)
  
  
    
    DROP TABLE #TmpAttendeeTripDetailsHost
    DROP TABLE #TimeLineTripAttendees
    
END
GO
