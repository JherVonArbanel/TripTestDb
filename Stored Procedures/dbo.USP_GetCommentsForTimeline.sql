SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel	
-- Create date: 12/May/2015
-- Description:	It is used to get comments on trip and event
-- Exec USP_GetCommentsForTimeline null
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetCommentsForTimeline]
	-- Add the parameters for the stored procedure here
	@StartDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
     CREATE TABLE #TimeLineComments            
	 (                 
		[commentKey] bigint NULL,
		[userKey] bigint NULL,
		[tripKey] bigint NULL,
		[eventKey] bigint NULL,
		[commentText] nvarchar(max) NULL,
		[createdDate] datetime  NULL,
	    userFirstName varchar(100) NULL,
	    userLastName varchar(100) NULL,
        ImageURL nvarchar(2000) NULL, 
        CreatedBy bigint NULL,
        startDate datetime NULL,
        endDate datetime NULL,
        destination varchar(50) NULL ,                                  
        EventName varchar(100) NULL,
        NoOfComments nvarchar(1000) NULL,
        toCountryName varchar(1000) NULL ,                                
	    toStateCode varchar(20) NULL ,                                
	    toCityName varchar(20) NULL ,                 
        privacyType int NULL,
        fromCityName varchar(100) NULL,
        tripComponents varchar(100) NULL,
        HotelChainName varchar(max) NULL,
        DestinationImage varchar(500) NULL,
        TripCreatorUserName varchar(100) NULL,
        LatestAirLineCode varchar(100) NULL ,                                                  
		LatestHotelChainCode varchar(100) NULL ,                                                  
		CarVendorCode varchar(10) NULL,
		HotelRating float(8) NULL,
		CarClass varchar(50) NULL,
		NumberOfCurrentAirStops int default(0),
		HotelRegionName varchar(100) null,
		originalPerPersonPriceAir float NULL,
		originalPerPersonPriceCar float NULL,
		originalPerPersonPriceHotel float NULL,
		NoOfFollowers int,
		TripCreatorImageURL varchar(100) NULL
	 )        
    
        INSERT INTO #TimeLineComments
        (
			[commentKey],
			[userKey],
			[tripKey],
			[eventKey],
			[commentText],
			[createdDate],
			userFirstName,
			userLastName,
			ImageURL, 
			CreatedBy,
			startDate,
			endDate,
			destination,                                  
			EventName,
			NoOfComments,
			toCountryName,                                
			toStateCode,                                
			toCityName,                 
			privacyType,
			fromCityName,
			tripComponents,
			HotelChainName  ,
			DestinationImage,
			TripCreatorUserName ,
			LatestAirLineCode  ,                                                  
			LatestHotelChainCode ,                                                  
			CarVendorCode ,
			HotelRating ,
			CarClass ,
			NumberOfCurrentAirStops ,
			HotelRegionName     ,
			originalPerPersonPriceAir ,
			originalPerPersonPriceCar ,
			originalPerPersonPriceHotel,
			NoOfFollowers ,
			TripCreatorImageURL
        )
    	SELECT C.commentKey,C.userKey,C.tripKey,C.eventKey,C.commentText,C.createdDate,U.userFirstName, U.userLastName, UM.ImageURL,
	       Case When C.eventKey> 0 then E.userKey else TD.userKey END CreatedBy
	       ,Case When C.eventKey> 0 then E.eventStartDate else TD.StartDate end startDate
	       ,Case When C.eventKey> 0 then E.eventEndDate else  TD.EndDate end endDate
	       ,Case When C.eventKey> 0 then E.eventDestination else TR.tripTo1 end destination
	       ,E.eventName,CM.NoOfComments,[toCountryName],[toStateCode],[toCityName],
	       T.privacyType,fromCityName,        
			 CASE                           
			  WHEN t.tripComponentType = 1 THEN 'Air'                          
			  WHEN t.tripComponentType = 2 THEN 'Car'                          
			  WHEN t.tripComponentType = 3 THEN 'Air,Car'                          
			  WHEN t.tripComponentType = 4 THEN 'Hotel'                          
			  WHEN t.tripComponentType = 5 THEN 'Air,Hotel'                          
			  WHEN t.tripComponentType = 6 THEN 'Car,Hotel'                          
			  WHEN t.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
			 END AS tripComponents ,COALESCE(HC.ChainName,TDetails.HotelName)  , TD.DestinationSmallImageURL AS DestinationImage,
			 (USR.userFirstName + ' ' + SUBSTRING(USR.userLastName,1,1) + '.') As TripCreatorUserName, [LatestAirLineCode], COALESCE(NULLIF(LatestHotelChainCode,''), 'DefaultHotel'),
			 [CarVendorCode], TDetails.HotelRating, TDetails.CarClass, TDetails.NumberOfCurrentAirStops,TDetails.HotelRegionName,
			 COALESCE(TDetails.originalPerPersonPriceAir,0) , COALESCE(TDetails.originalPerPersonPriceCar,0) , COALESCE(TDetails.originalPerPersonPriceHotel,0),
			 (select COUNT(*) from TripSaved where CrowdId IN (select CrowdId from TripSaved where tripSavedKey IN (select tripSavedKey from Trip where tripKey = TD.tripKey))), 
			 USM.ImageURL
		 
	FROM Comments  C 
		INNER JOIN Vault..[User] U  ON C.userKey = U.userKey
		INNER JOIN Loyalty..UserMap UM ON UM.UserId = U.userKey
		LEFT OUTER JOIN trip..Trip TD ON TD.tripKey = C.tripKey
		INNER JOIN Vault..[User] USR ON USR.userKey = TD.userKey
		INNER JOIN Loyalty..UserMap USM ON USM.UserId = USR.userKey
		LEFT OUTER JOIN trip..TripDetails TDetails ON TDetails.tripKey = TD.tripKey
		LEFT OUTER JOIN trip..Trip T ON T.tripKey = TD.tripKey AND  T.startDate > GETDATE() AND T.isUserCreatedSavedTrip = 1
		LEFT OUTER JOIN trip..TripRequest TR ON TR.tripRequestKey = TD.tripRequestKey
		LEFT OUTER JOIN HotelContent..HotelChains HC ON HC.ChainCode = TDetails.LatestHotelChainCode
		LEFT OUTER JOIN trip..[Events] E ON E.eventKey = C.eventKey 
		LEFT OUTER JOIN (
		 SELECT COUNT(*) As NoOfComments, tripKey FROM Comments WHERE tripKey > 0 Group By tripKey
		) CM ON CM.tripKey = C.tripKey
		WHERE (@StartDate is null OR C.createdDate > @StartDate) AND  Convert(Date,TDetails.lastUpdatedDate)= Convert(Date,GETDATE())
	Order by createdDate Desc
    
  SELECT * FROM 
  (
    SELECT ROW_NUMBER() OVER (PARTITION BY tripKey ORDER BY tripkey,userkey DESC) AS ID, TD.* FROM #TimeLineComments TD  
  )TD WHERE TD.ID = 1
  DROP TABLE #TimeLineComments   
END
GO
