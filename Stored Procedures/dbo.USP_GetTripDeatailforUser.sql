SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
--exec USP_GetTripDeatailforUser 562416, 5 ,'562416,560799,561945'   
CREATE PROCEDURE [dbo].[USP_GetTripDeatailforUser]    
@UserKey BIGINT = 0,    
@siteKey INT = 0  ,  
@listoffriends varchar(1000)= ''  
AS    
BEGIN    
   
DECLARE @friendstable AS TABLE  
(  
friendsUserKey VARCHAR(100)  
)  
  
INSERT INTO @friendstable  SELECT @UserKey  
  
INSERT INTO @friendstable SELECT * From dbo.ufn_DelimiterToTable(@listoffriends,',')  
    
    
--SELECT * FROM @friendstable  
  
  
CREATE TABLE #AttendeeTravelDetails                
(                
eventAttendeekey BIGINT,                
attendeeTripKey BIGINT                
)                
    
IF OBJECT_ID('tempdb..#EventTripMapping') IS NOT NULL                
DROP TABLE #EventTripMapping                
    
CREATE TABLE #EventTripMapping                
(                
tripKey BIGINT,                
eventKey BIGINT                
)                
    
IF OBJECT_ID('tempdb..#EventAttendees') IS NOT NULL                
DROP TABLE #EventAttendees                
    
CREATE TABLE #EventAttendees                
(                
 tripKey BIGINT,             
 eventKey BIGINT,                
 eventAttendeekey BIGINT,                
 userKey BIGINT,                
 eventViewerShipType INT,              
 AttendeeStatusKey INT DEFAULT(0)
)     
    
IF OBJECT_ID('tempdb..#Tripdetails') IS NOT NULL                
DROP TABLE #Tripdetails               
CREATE TABLE #Tripdetails                               
(                                  
 -- TripdetailsKey int identity (1,1) ,    
 Id INT,                                  
 tripKey int NULL,         
 tripName varchar(500) null,                               
 tripsavedKey uniqueidentifier NULL ,                                    
 triprequestkey int NULL ,                 
 userKey INT,                                   
 tripstartdate datetime NULL ,                                    
 tripenddate datetime NULL ,                                    
 tripfrom varchar(20) NULL ,                                    
 tripTo varchar(20) NULL ,                            
 tripComponentType int NULL ,                    
 tripComponents varchar(100) NULL ,                                                      
 rankRating float NULL ,                                    
 tripAirsavings float NULL ,                                      
 tripcarsavings float NULL ,                                    
 triphotelsavings float NULL,                                    
 --isOffer bit  NULL,                                    
 --OfferImageURL varchar(500) NULL,                    
 --LinktoPage varchar(500) NULL,                  
 currentTotalPrice FLOAT NULL,                  
 originalTotalPrice FLOAT NULL,                  
 UserName VARCHAR(200),                
 FacebookUserUrl VARCHAR(500),                
 WatchersCount INT,                
 LikeCount INT ,    
 CommentCount int,       
 ShareCount int,       
 --ThemeType INT DEFAULT(0),                
 IsWatcher BIT DEFAULT(0),                
 --BookersCount INT DEFAULT(0),                
 tripPurchasedKey uniqueidentifier NULL,                
 --FastestTrending FLOAT NULL,                
 TotalSavings FLOAT,                
 --RowNumber INT,                
 Rating FLOAT,                
 --AirSegmentCabinAbbrevation VARCHAR(50),                
 AirSegmentCabin VARCHAR(50),                
 --CarClassAbbrevation VARCHAR(100),                
 CarClass VARCHAR(100),                
 AirRequestTypeName VARCHAR(50),    
 NoOfStops VARCHAR(20),      
 HotelRegionName VARCHAR(100),      
 TripScoring FLOAT,    
 DestinationImageURL VARCHAR(500),                
 SavingsRanking FLOAT DEFAULT(0),                
 --Recency FLOAT DEFAULT(0),                
 --RecencyRanking FLOAT DEFAULT(0),                
 --Proximity INT DEFAULT(0),                
 --ProximityRanking FLOAT DEFAULT(0),                
 --SocialRanking FLOAT DEFAULT(0),                
 --ComponentRanking FLOAT DEFAULT(0),                
 FromCity VARCHAR(100),                
 FromState VARCHAR(100),                
 FromCountry VARCHAR(100),                
 ToCity VARCHAR(100),                
 ToState VARCHAR(100),                
 ToCountry VARCHAR(100),                            
 tripStatusKey INT DEFAULT(0),                
 IsMyTrip BIT DEFAULT(0),                
 LatestDealAirPriceTotal FLOAT DEFAULT(0),                
 LatestDealHotelPriceTotal FLOAT DEFAULT(0),                
 LatestDealCarPriceTotal FLOAT DEFAULT(0),                
 LatestDealAirPricePerPerson FLOAT DEFAULT(0),                 
 LatestDealHotelPricePerPerson FLOAT DEFAULT(0),                
 LatestDealCarPricePerPerson FLOAT DEFAULT(0),                  
 --IsBackFillData BIT DEFAULT(0),                
 --IsZeroPriceAvailable BIT DEFAULT(0),                
 LatestAirLineCode VARCHAR(30),                
 LatestAirlineName VARCHAR(64),                  
 LatestHotelChainCode VARCHAR(20),                  
 HotelName VARCHAR(100),                
 CarVendorCode VARCHAR(50),                
 LatestCarVendorName VARCHAR(30),                
 CurrentHotelsComId VARCHAR(10),                
 LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),                
 --DateRanking FLOAT DEFAULT(0),                
 NumberOfCurrentAirStops INT DEFAULT(0),                
 --ExactCityMatchRanking FLOAT DEFAULT(0),                
 LatestHotelRegionId INT DEFAULT(0),                
 CrowdId BIGINT,                
 LatestDealAirSavingsTotal FLOAT DEFAULT(0),           
 LatestDealCarSavingsTotal FLOAT DEFAULT(0),                
 LatestDealHotelSavingsTotal FLOAT DEFAULT(0),                
 LatestDealAirSavingsPerPerson FLOAT DEFAULT(0),                  
 LatestDealCarSavingsPerPerson FLOAT DEFAULT(0),                
 LatestDealHotelSavingsPerPerson FLOAT DEFAULT(0),                
 IsEventAvailable BIT DEFAULT(0),                
 EventKey BIGINT DEFAULT(0),                
 TotalTripSavings FLOAT DEFAULT(0),                
 TotalTripCount INT DEFAULT(0) ,               
 AttendeeStatusKey INT DEFAULT(0),     
 TripPrivacyType INT DEFAULT(0),    
 HotelNoOfNights INT DEFAULT(1),    
 RecommendedHotelResponseKey UNIQUEIDENTIFIER ,    
 InCrowd INT DEFAULT(0),    
 HotelId BIGINT DEFAULT(0),    
 TripStatusType varchar(100) DEFAULT null,    
 TripOrder BIGINT DEFAULT(0)    
)      
  
IF OBJECT_ID('tempdb..#FriendsCrowdTripdetails') IS NOT NULL                
DROP TABLE #FriendsCrowdTripdetails  
CREATE TABLE #FriendsCrowdTripdetails  
(                                  
 -- TripdetailsKey int identity (1,1) ,   
 Id INT,                                   
 tripKey int NULL,         
 tripName varchar(500) null,                               
 tripsavedKey uniqueidentifier NULL ,                                    
 triprequestkey int NULL ,                 
 userKey INT,                                   
 tripstartdate datetime NULL ,                                    
 tripenddate datetime NULL ,                                    
 tripfrom varchar(20) NULL ,                                    
 tripTo varchar(20) NULL ,                            
 tripComponentType int NULL ,                    
 tripComponents varchar(100) NULL ,                                                      
 rankRating float NULL ,                                    
 tripAirsavings float NULL ,                                      
 tripcarsavings float NULL ,                                    
 triphotelsavings float NULL,                                    
 --isOffer bit  NULL,                                    
 --OfferImageURL varchar(500) NULL,                    
 --LinktoPage varchar(500) NULL,                  
 currentTotalPrice FLOAT NULL,                  
 originalTotalPrice FLOAT NULL,                  
 UserName VARCHAR(200),                
 FacebookUserUrl VARCHAR(500),                
 WatchersCount INT,              
 LikeCount INT ,    
 CommentCount int,       
 ShareCount int,       
 --ThemeType INT DEFAULT(0),                
 IsWatcher BIT DEFAULT(0),                
 --BookersCount INT DEFAULT(0),                
 tripPurchasedKey uniqueidentifier NULL,                
 --FastestTrending FLOAT NULL,                
 TotalSavings FLOAT,                
 --RowNumber INT,                
 Rating FLOAT,                
 --AirSegmentCabinAbbrevation VARCHAR(50),                
 AirSegmentCabin VARCHAR(50),                
 --CarClassAbbrevation VARCHAR(100),                
 CarClass VARCHAR(100),                
 AirRequestTypeName VARCHAR(50),    
 NoOfStops VARCHAR(20),      
 HotelRegionName VARCHAR(100),      
 TripScoring FLOAT,    
 DestinationImageURL VARCHAR(500),                
 SavingsRanking FLOAT DEFAULT(0),                
 --Recency FLOAT DEFAULT(0),                
 --RecencyRanking FLOAT DEFAULT(0),                
 --Proximity INT DEFAULT(0),                
 --ProximityRanking FLOAT DEFAULT(0),                
 --SocialRanking FLOAT DEFAULT(0),                
 --ComponentRanking FLOAT DEFAULT(0),                
 FromCity VARCHAR(100),                
 FromState VARCHAR(100),                
 FromCountry VARCHAR(100),                
 ToCity VARCHAR(100),                
 ToState VARCHAR(100),                
 ToCountry VARCHAR(100),                            
 tripStatusKey INT DEFAULT(0),                
 IsMyTrip BIT DEFAULT(0),                
 LatestDealAirPriceTotal FLOAT DEFAULT(0),                
 LatestDealHotelPriceTotal FLOAT DEFAULT(0),                
 LatestDealCarPriceTotal FLOAT DEFAULT(0),                
 LatestDealAirPricePerPerson FLOAT DEFAULT(0),                 
 LatestDealHotelPricePerPerson FLOAT DEFAULT(0),                
 LatestDealCarPricePerPerson FLOAT DEFAULT(0),                  
 --IsBackFillData BIT DEFAULT(0),                
 --IsZeroPriceAvailable BIT DEFAULT(0),                
 LatestAirLineCode VARCHAR(30),                
 LatestAirlineName VARCHAR(64),                  
 LatestHotelChainCode VARCHAR(20),                  
 HotelName VARCHAR(100),                
 CarVendorCode VARCHAR(50),                
 LatestCarVendorName VARCHAR(30),                
 CurrentHotelsComId VARCHAR(10),                
 LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),                
 --DateRanking FLOAT DEFAULT(0),                
 NumberOfCurrentAirStops INT DEFAULT(0),                
 --ExactCityMatchRanking FLOAT DEFAULT(0),                
 LatestHotelRegionId INT DEFAULT(0),                
 CrowdId BIGINT,                
 LatestDealAirSavingsTotal FLOAT DEFAULT(0),           
 LatestDealCarSavingsTotal FLOAT DEFAULT(0),                
 LatestDealHotelSavingsTotal FLOAT DEFAULT(0),                
 LatestDealAirSavingsPerPerson FLOAT DEFAULT(0),                  
 LatestDealCarSavingsPerPerson FLOAT DEFAULT(0),                
 LatestDealHotelSavingsPerPerson FLOAT DEFAULT(0),                
 IsEventAvailable BIT DEFAULT(0),                
 EventKey BIGINT DEFAULT(0),                
 TotalTripSavings FLOAT DEFAULT(0),                
 TotalTripCount INT DEFAULT(0) ,               
 AttendeeStatusKey INT DEFAULT(0),     
 TripPrivacyType INT DEFAULT(0),    
 HotelNoOfNights INT DEFAULT(1),    
 RecommendedHotelResponseKey UNIQUEIDENTIFIER ,    
 InCrowd INT DEFAULT(0),    
 HotelId BIGINT DEFAULT(0),    
 TripStatusType varchar(100) DEFAULT null,    
 TripOrder BIGINT DEFAULT(0)    
)      
   
  
  
/*=================  preparing data for Trip details of logged in user ===================== */  
  
INSERT INTO #Tripdetails                
(   
Id,                 
 tripKey,         
 tripName ,           
 tripsavedKey,                
 triprequestkey,                
 userKey,                
 tripstartdate,                
 tripenddate,                
 tripfrom,                
 tripTo,                 
 tripComponentType,                
 tripComponents,                 
 rankRating,                 
 currentTotalPrice,                 
 originalTotalPrice,                
 UserName,                 
 FacebookUserUrl,                 
 WatchersCount,                 
 LikeCount,      
 CommentCount,     
 ShareCount,              
 --ThemeType,                 
 tripPurchasedKey,                
 --BookersCount,                 
 --FastestTrending,                
 TotalSavings,                
 --RowNumber,                
 Rating,                
 --AirSegmentCabinAbbrevation,                
 AirSegmentCabin,                
 --CarClassAbbrevation,                
 CarClass,                
 AirRequestTypeName,                
 NoOfStops,                
 HotelRegionName,                
 DestinationImageURL,                
 FromCity ,                
 FromState ,                
 FromCountry ,                
 ToCity ,                
 ToState ,                
 ToCountry,                         
 tripStatusKey,                
 IsMyTrip,                
 LatestDealAirPriceTotal,                
 LatestDealHotelPriceTotal,                
 LatestDealCarPriceTotal,                
 LatestDealAirPricePerPerson,                
 LatestDealHotelPricePerPerson,                
 LatestDealCarPricePerPerson,                
 --IsZeroPriceAvailable,                
 LatestAirLineCode ,                
 LatestAirlineName ,                  
 LatestHotelChainCode ,                  
 HotelName ,                
 CarVendorCode ,                
 LatestCarVendorName,                 
 CurrentHotelsComId,                
 LatestDealHotelPricePerPersonPerDay,                
 NumberOfCurrentAirStops,                
 LatestHotelRegionId,                
 CrowdId,                
 LatestDealAirSavingsTotal,                
 LatestDealCarSavingsTotal,                
 LatestDealHotelSavingsTotal,                
 LatestDealAirSavingsPerPerson,                  
 LatestDealCarSavingsPerPerson,                
 LatestDealHotelSavingsPerPerson,              
 AttendeeStatusKey,   -- added by pradeep                  
 TripPrivacyType,    
 HotelNoOfNights,    
 RecommendedHotelResponseKey ,                     
 InCrowd,    
 HotelId ,    
 TripStatusType,    
 TripOrder    
)                             
SELECT   
 ROW_NUMBER() OVER(PARTITION BY T1.tripKey order by T1.tripKey asc) AS Id,                 
 t1.tripKey,      
 t1.tripName,               
 t1.tripsavedKey,                
 t1.triprequestkey,                
 TD.userKey,                
 TD.tripStartDate,                 
 TD.tripEndDate,                
 TD.tripFrom,                 
 TD.tripTo,                 
 t1.tripComponentType,                 
 CASE                           
 WHEN t1.tripComponentType = 1 THEN 'Air'                          
 WHEN t1.tripComponentType = 2 THEN 'Car'                          
 WHEN t1.tripComponentType = 3 THEN 'Air,Car'                          
 WHEN t1.tripComponentType = 4 THEN 'Hotel'                          
 WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'                          
 WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'                          
 WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'                          
 END AS tripComponents,                                     
 0 as [Rank],  
 
 /*below line is commented because if either of the component deal is failed then it was giving price mis-match on trip section pgae. Hence written case statement for all scenario. */
 --ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0) as CurrentTotalPrice,  
  
--CASE     
-- WHEN T1.tripComponentType=1 THEN CASE WHEN ((ISNULL(TD.latestDealAirPriceTotal,0)) = 0) THEN ISNULL(TD.originalTotalPriceAir,0) ELSE ISNULL(TD.latestDealAirPriceTotal,0) END
-- WHEN T1.tripComponentType=2 THEN CASE WHEN ((ISNULL(TD.latestDealCarPriceTotal,0)) = 0) then ISNULL(TD.originalTotalPriceCar,0) else ISNULL(TD.latestDealCarPriceTotal,0) end
-- WHEN T1.tripComponentType=3 THEN /* Air  + Car*/
-- CASE 
-- WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) = 0   THEN ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) 
-- WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) <> 0   THEN ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.latestDealCarPriceTotal,0) 
-- WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) = 0   THEN ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.originalTotalPriceCar,0) 
-- ELSE ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) END   
 
-- WHEN T1.tripComponentType=4 THEN CASE WHEN ((ISNULL(TD.latestDealHotelPriceTotal,0)) = 0) then ISNULL(TD.originalTotalPriceHotel,0) else ISNULL(TD.latestDealHotelPriceTotal,0) end
 
-- WHEN T1.tripComponentType=5 THEN /* Air  + Hotel*/
-- CASE 
-- WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) = 0   THEN ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceHotel,0) 
-- WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) <> 0   THEN ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.latestDealHotelPriceTotal,0) 
-- WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) = 0   THEN ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.originalTotalPriceHotel,0) 
-- ELSE ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0) END  
 
 
-- WHEN T1.tripComponentType=6 THEN /* Hotel + Car*/
-- CASE 
-- WHEN (ISNULL(latestDealHotelPriceTotal, 0)) = 0 and (ISNULL(latestDealCarPriceTotal, 0)) = 0   THEN ISNULL(TD.originalTotalPriceHotel,0) + ISNULL(TD.originalTotalPriceCar,0) 
-- WHEN (ISNULL(latestDealHotelPriceTotal, 0)) = 0 and (ISNULL(latestDealCarPriceTotal, 0)) <> 0   THEN ISNULL(TD.originalTotalPriceHotel,0) + ISNULL(TD.latestDealCarPriceTotal,0) 
-- WHEN (ISNULL(latestDealHotelPriceTotal, 0)) <> 0 and (ISNULL(latestDealCarPriceTotal, 0)) = 0   THEN ISNULL(TD.latestDealHotelPriceTotal,0) + ISNULL(TD.originalTotalPriceCar,0) 
-- ELSE ISNULL(TD.latestDealHotelPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) END    
 
-- WHEN T1.tripComponentType=7 THEN /* Air + Hotel + Car*/
 CASE 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) = 0   THEN (ISNULL(TD.originalTotalPriceAir, 0)) +  ISNULL(TD.originalTotalPriceHotel,0) + ISNULL(TD.originalTotalPriceCar,0) 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) <> 0   THEN (ISNULL(TD.originalTotalPriceAir, 0)) +  ISNULL(TD.latestDealHotelPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) <> 0   THEN (ISNULL(TD.latestDealAirPriceTotal, 0)) +  ISNULL(TD.originalTotalPriceHotel,0) + ISNULL(TD.latestDealCarPriceTotal,0) 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) = 0   THEN (ISNULL(TD.latestDealAirPriceTotal, 0)) +  ISNULL(TD.latestDealHotelPriceTotal,0) + ISNULL(TD.originalTotalPriceCar,0) 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) <> 0   THEN (ISNULL(TD.originalTotalPriceAir, 0)) +  ISNULL(TD.originalTotalPriceHotel,0) + ISNULL(TD.latestDealCarPriceTotal,0) 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) = 0   THEN (ISNULL(TD.originalTotalPriceAir, 0)) +  ISNULL(TD.latestDealHotelPriceTotal,0) + ISNULL(TD.originalTotalPriceCar,0) 
 WHEN (ISNULL(TD.latestDealAirPriceTotal, 0)) <> 0 and (ISNULL(TD.latestDealHotelPriceTotal, 0)) = 0 and (ISNULL(TD.latestDealCarPriceTotal, 0)) = 0   THEN (ISNULL(TD.latestDealAirPriceTotal, 0)) +  ISNULL(TD.originalTotalPriceHotel,0) + ISNULL(TD.originalTotalPriceCar,0) 
 ELSE (ISNULL(TD.latestDealAirPriceTotal, 0)) + ISNULL(TD.latestDealHotelPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) END    
 --ELSE ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0) END 
  as CurrentTotalPrice,  
                            
 ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0) as OriginalTotalPrice,               
 CASE                 
 WHEN T1.privacyType = 2 AND TD.userKey != @UserKey THEN       
 (SELECT distinct originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey)    
 ELSE    
 UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'                
 END AS UserName,                        
    
 CASE                 
 WHEN T1.privacyType = 2 AND TD.userKey != @UserKey THEN       
 UM.BadgeUrl    
 ELSE    
 CASE WHEN UM.UserImageData IS NOT NULL THEN '/user/image/' + CONVERT(VARCHAR, TD.userKey) ELSE  ISNULL(UM.ImageURL,'') END                  
 END AS FacebookUserUrl,    
    
 --ISNULL(TS.SplitFollowersCount,0) as WatchersCount,                
 0 as WatchersCount,    
 0 as LikeCount,    
 0 as CommentCount ,    
 0 as ShareCount ,    
 --ISNULL(D.PrimaryTripType,0) as  ThemeType,                
 T1.tripPurchasedKey,                
 --0 as BookersCount,                
 --0 as FastestTrending,                
 --CASE                 
 --WHEN TD.userKey = @UserKey  THEN                  
 ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)                
 --ELSE                   
 --ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)                    
 --END 
 as TotalSavings,                
 --0,                
 HotelRating,                 
 --'' -- AirSegmentCabinAbbrevation                
 TD.AirCabin,  -- AirSegmentCabin                
 --,'' -- CarClassAbbrevation                
 TD.CarClass, -- CarClass                
 TD.AirRequestTypeName, -- AirRequestTypeName                
 TD.NumberOfCurrentAirStops, -- NoOfStops                
 TD.HotelRegionName,                
 T1.DestinationSmallImageURL,                
 TD.fromCityName,                
 CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,                   
 CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,                
 TD.toCityName,                
 CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,                
 CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,                         
 T1.tripStatusKey,                
 CASE WHEN TD.userKey = @UserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ...                 
 CASE WHEN TD.userKey = @UserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,                
 CASE WHEN TD.userKey = @UserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,                          
 ISNULL(TD.latestDealCarPriceTotal,0) ,                
 --ISNULL(TD.latestDealAirPricePerPerson,0) ,                
 --ISNULL(TD.LatestDealHotelPricePerPerson,0) ,                          
 --ISNULL(TD.latestDealCarPricePerPerson,0) ,       
 CASE     
 WHEN T1.tripComponentType=1 THEN CASE WHEN (ISNULL(latestDealAirPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceAir,0) ELSE latestDealAirPricePerPerson END    
 WHEN T1.tripComponentType=3 THEN CASE WHEN (ISNULL(latestDealAirPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceAir,0) ELSE latestDealAirPricePerPerson END    
 WHEN T1.tripComponentType=5 THEN CASE WHEN (ISNULL(latestDealAirPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceAir,0) ELSE latestDealAirPricePerPerson END    
 WHEN T1.tripComponentType=7 THEN CASE WHEN (ISNULL(latestDealAirPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceAir,0) ELSE latestDealAirPricePerPerson END    
 ELSE ISNULL(latestDealAirPricePerPerson,0) END AS latestDealAirPricePerPerson,          
 CASE     
 WHEN T1.tripComponentType=4 THEN CASE WHEN (ISNULL(latestDealHotelPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceHotel,0) ELSE latestDealHotelPricePerPerson END    
 WHEN T1.tripComponentType=5 THEN CASE WHEN (ISNULL(latestDealHotelPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceHotel,0) ELSE latestDealHotelPricePerPerson END    
 WHEN T1.tripComponentType=6 THEN CASE WHEN (ISNULL(latestDealHotelPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceHotel,0) ELSE latestDealHotelPricePerPerson END    
 WHEN T1.tripComponentType=7 THEN CASE WHEN (ISNULL(latestDealHotelPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceHotel,0) ELSE latestDealHotelPricePerPerson END    
 ELSE ISNULL(latestDealHotelPricePerPerson,0) END AS latestDealHotelPricePerPerson,      
 CASE     
 WHEN T1.tripComponentType=2 THEN CASE WHEN (ISNULL(latestDealCarPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceCar,0) ELSE latestDealCarPricePerPerson END    
 WHEN T1.tripComponentType=3 THEN CASE WHEN (ISNULL(latestDealCarPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceCar,0) ELSE latestDealCarPricePerPerson END    
 WHEN T1.tripComponentType=6 THEN CASE WHEN (ISNULL(latestDealCarPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceCar,0) ELSE latestDealCarPricePerPerson END    
 WHEN T1.tripComponentType=7 THEN CASE WHEN (ISNULL(latestDealCarPricePerPerson, 0)) = 0 THEN ISNULL(originalPerPersonPriceCar,0) ELSE latestDealCarPricePerPerson END    
 ELSE ISNULL(latestDealCarPricePerPerson,0) END AS latestDealCarPricePerPerson,     
 --CASE                 
 -- WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'                
 -- WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'                
 -- WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
   
   
 -- WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'                
 -- WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'         
  
   
    
 -- WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'         
  
    
    
 -- WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                    
 -- ELSE 0                    
 --END,                
 ISNULL(LatestAirLineCode,''),                
 ISNULL(LatestAirlineName,''),                
 ISNULL(LatestHotelChainCode,''),                
 ISNULL(HotelName,''),                
 ISNULL(CarVendorCode,''),                
 ISNULL(LatestCarVendorName,''),                           
 ISNULL(CurrentHotelsComId, ''),                
 ISNULL(TD.LatestDealHotelPricePerPersonPerDay,0),                
 ISNULL(TD.NumberOfCurrentAirStops,0),                
 ISNULL(TD.LatestHotelRegionId,0),                
 TD.crowdId ,                
 ISNULL(TD.latestDealAirSavingsTotal,0),                
 ISNULL(TD.latestDealCarSavingsTotal,0),                
 ISNULL(TD.latestDealHotelSavingsTotal,0),                
 ISNULL(TD.LatestDealAirSavingsPerPerson,0) ,                  
 ISNULL(TD.LatestDealCarSavingsPerPerson,0) ,                
 ISNULL(TD.LatestDealHotelSavingsPerPerson,0),              
 ISNULL(EA.attendeeStatusKey,0),    
 ISNULL(T1.PrivacyType,0),    
 ISNULL(TD.HotelNoOfDays,1),    
 TD.HotelResponseKey,  
 0 --(SELECT COUNT(*) FROM Trip..TripSaved WHERE CrowdId IN(SELECT CrowdId FROM Trip..TripDetails WHERE tripKey = t1.tripKey) AND userKey = @parentLoggedInUser) AS InCrowd    
 ,TD.LatestHotelId   ,    
 --CASE WHEN T1.tripPurchasedKey IS NOT NULL THEN 'purchased' ELSE    
 --CASE WHEN T1.startDate < GETDATE() THEN 'expired' ELSE 'current' END    
 --END    
 CASE WHEN T1.tripPurchasedKey IS NOT NULL THEN 'purchased' ELSE null END,    
 CASE WHEN T1.tripPurchasedKey IS NOT NULL THEN 1 ELSE CASE WHEN TD.tripStartDate > GETDATE() THEN 2 ELSE 3 END    
 END    
     
FROM                 
 Trip..TripDetails TD WITH (NOLOCK)                         
 INNER JOIN Trip..Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey                 
 INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                                
 LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId      
 --LEFT JOIN Vault..AirPreference AP WITH (NOLOCK) ON UI.userKey = AP.userKey             
 --LEFT JOIN EventAttendees EA WITH (NOLOCK) ON T1.tripKey = EA.eventKey  --added by pradeep    
 LEFT JOIN  Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON T1.tripKey = ATD.attendeeTripKey and ATD.eventAttendeekey is not null     
 LEFT join Trip..EventAttendees EA WITH (NOLOCK) ON ATD.eventAttendeekey = EA.eventKey      
 --LEFT JOIN TripSaved TS WITH (NOLOCK) ON TD.tripSavedKey = TS.tripSavedKey                 
 where  T1.tripStatusKey not in ( 17,5 )    
 AND T1.IsWatching = 1                
 --AND TD.userKey = @UserKey                
 AND TD.userKey in (select friendsUserKey from @friendstable)  
 AND T1.isUserCreatedSavedTrip =1 -- only user created save trip not system generated.      
 AND T1.tripSavedKey IS NOT NULL    
 AND T1.siteKey = @siteKey    
 --order by T1.tripKey desc, T1.userKey asc  
    
    
--INSERT INTO #AttendeeTravelDetails                
--SELECT                 
-- ATD.eventAttendeekey, attendeeTripKey                 
--FROM                 
-- Trip..TripDetails TD                    
-- INNER JOIN                 
-- Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON TD.tripKey = ATD.attendeeTripKey                
    
    
---- GET TRIP KEY AND EVENT KEY FROM ATTENDEE KEY ...                
--INSERT INTO #EventTripMapping                
--SELECT                  
-- ATD.attendeeTripKey,                
-- eventKey                    
--FROM       
-- Trip..EventAttendees                
-- INNER JOIN                 
-- #AttendeeTravelDetails ATD WITH (NOLOCK) ON EventAttendees.eventAttendeeKey = ATD.eventAttendeekey                
    
---- GET CONSOLIDATED MAPPING OF TRIPKEY, EVENTKEY, ATTENDEE KEY, USER KEY ...                
--INSERT INTO #EventAttendees                
--SELECT                 
-- ETM.tripKey,                   
-- EA.eventKey,                 
-- EA.eventAttendeeKey,                     
-- EA.userKey,                
-- 0,              
-- EA.attendeeStatusKey                 
--FROM                 
-- Trip..EventAttendees EA                
-- INNER JOIN                 
-- #EventTripMapping ETM WITH (NOLOCK) ON EA.eventKey = ETM.eventKey                
    
--UPDATE EA                
-- SET EA.eventViewerShipType = EV.eventViewershipType 
-- FROM #EventAttendees EA                 
-- INNER JOIN Trip..Events EV WITH (NOLOCK) ON EA.eventKey = EV.eventKey         

    
--UPDATE TD                
--SET                 
-- IsEventAvailable = 1,                
-- EventKey = EA.eventKey,              
-- AttendeeStatusKey = EA.AttendeeStatusKey,      
-- tripName = E.eventName    
--FROM #TripDetails TD                
-- INNER JOIN #EventAttendees EA WITH (NOLOCK) ON TD.tripKey = EA.tripKey      
-- Inner join Trip..Events E WITH (NOLOCK) ON E.eventKey = EA.eventKey    
-- WHERE EA.userKey = @UserKey      




 UPDATE TD
 SET
 IsEventAvailable = 1,                
 EventKey = EA.eventKey,              
 AttendeeStatusKey = EA.AttendeeStatusKey,
 tripName = CASE WHEN E.groupKey> 0 THEN FG.Name ELSE CASE WHEN E.eventKey >0 THEN E.eventName ELSE T.tripName END END 
FROM 
 #TripDetails TD                  
 INNER JOIN Trip..Trip T WITH (NOLOCK) ON T.tripKey = TD.tripKey and T.siteKey = @siteKey
 INNER JOIN Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON TD.tripKey = ATD.attendeeTripKey  
 INNER JOIN Trip..EventAttendees EA WITH (NOLOCK) ON EA.eventAttendeeKey = ATD.eventAttendeekey and Ea.userKey = @UserKey
 INNER JOIN Trip..Events E WITH (NOLOCK) ON EA.eventKey = E.eventKey and E.userKey = @UserKey
 LEFT OUTER JOIN vault..FriendsGroups FG WITH (NOLOCK) ON  FG.GroupKey = E.groupKey



  
    
/*update No. of follower */    
UPDATE TD     
 SET WatchersCount = (SELECT COUNT(distinct(T.userKey)) FROM Trip..Trip T WITH(NOLOCK) INNER  JOIN Trip..TripSaved TS WITH(NOLOCK) ON T.tripSavedKey = TS.tripSavedKey WHERE T.IsWatching = 1 AND TS.crowdId = TD.CrowdId)     
FROM #Tripdetails TD    


/*update No. of commnets*/    
UPDATE TD     
 SET CommentCount = ( select COUNT(tripKey) from Trip..Comments where tripKey = TD.tripKey)  
FROM #Tripdetails TD    
INNER JOIN Trip..Comments TC WITH (NOLOCK) ON TC.tripKey = TD.tripKey  
     
/*update No. of likes */    
UPDATE TD     
 SET LikeCount =( select COUNT(tripKey) from Trip..TripLike where tripKey = TD.tripKey)  
FROM #Tripdetails TD    
  INNER JOIN Trip..TripLike TL WITH (NOLOCK) ON TL.tripKey = TD.tripKey  
    
UPDATE T    
SET  TripStatusType = 'followed'    
FROM #Tripdetails T    
INNER JOIN Trip..TripDetails TD WITH (NOLOCK) ON TD.tripKey = T.tripKey    
INNER JOIN Trip..TripSaved TS WITH (NOLOCK) ON TS.tripSavedKey = TD.tripSavedKey    
where T.userKey = @UserKey and TS.parentSaveTripKey IS NOT NULL    

  
INSERT INTO #FriendsCrowdTripdetails  
select * from #Tripdetails where userKey <> @UserKey  and tripStatusKey in ( 14,2)

--update #Tripdetails
--set TripOrder = 3

/*=================  end of preparing data for Trip details of logged in user  ===================== */  
    
    
/*=================  preparing data for trip follower details  ===================== */  
    
DECLARE @TripFollowersDetails AS TABLE          
(       
 Id int,       
 userFirstName VARCHAR(200) DEFAULT NULL,    
 userLastName VARCHAR(200) DEFAULT NULL,    
 userKey INT,          
 userName VARCHAR(200) DEFAULT NULL,          
 userImageURL VARCHAR(500)DEFAULT NULL,          
 homeAirportCode VARCHAR(100) DEFAULT NULL,       
 tripKey INT,    
 isShowMyPic INT,    
 CityName VARCHAR(50) DEFAULT NULL,    
 ChatCount INT DEFAULT(0),    
 Isfollower bit DEFAULT(0)    
 --imageData Image    
)          
    
    
INSERT INTO @TripFollowersDetails     
 SELECT ROW_NUMBER() OVER(PARTITION BY Ts.userKey ORDER BY Ts.userKey ASC), U.userFirstName,U.userLastName,Ts.userKey, ISNULL(U.userFirstName,'') + ' ' + LEFT(ISNULL(U.userLastName,''),1) + '.' as [userName],     
 CASE WHEN TD.TripPrivacyType=2 THEN ISNULL(UM.BadgeUrl,'')     
   WHEN TD.TripPrivacyType=1 THEN ISNULL(UM.ImageURL,'')     
   ELSE ISNULL(UM.ImageURL,'') END     
 AS [userImageURL],    
 AR.originAirportCode,T.tripKey,T.IsShowMyPic, AL.CityName,0,0    
 --,UM.UserImageData    
 FROM Trip..Trip T WITH(NOLOCK)    
 --INNER JOIN #Tripdetails TD WITH(NOLOCK) ON T.tripSavedKey = TD.tripSavedKey   
 INNER JOIN #Tripdetails TD WITH(NOLOCK) ON T.tripKey = TD.tripKey  
 INNER JOIN Trip..TripSaved TS WITH(NOLOCK) ON Td.CrowdId = TS.CrowdId    
 LEFT JOIN Loyalty..UserMap UM WITH(NOLOCK) ON TD.userKey = UM.UserId     
 INNER JOIN vault..[User] U WITH(NOLOCK) ON TS.userKey = U.userKey      
 INNER JOIN vault..AirPreference AR WITH(NOLOCK) ON TS.userKey = AR.userKey     
 LEFT OUTER JOIN Trip..AirportLookup AL WITH(NOLOCK) ON AR.originAirportCode = AL.AirportCode    
 ORDER BY TD.userKey    
    
--INSERT INTO @TripFollowersDetails    
--select 0,'','',0,'','','',0,0,'',0,1  
  
UPDATE TFD     
SET ChatCount = UCM.readCount    
FROM @TripFollowersDetails TFD    
INNER JOIN Trip..UserChatMapping UCM WITH (NOLOCK) ON UCM.fromUserKey = TFD.userKey    
where UCM.toUserKey = @UserKey     
  
  
UPDATE TFD     
SET     
 userImageURL = case when TFD.isShowMyPic=2 then  ISNULL(UM.BadgeUrl,'')   when TFD.isShowMyPic=1 then ISNULL(UM.ImageURL,'') else ISNULL(UM.ImageURL,'') end            
 FROM @TripFollowersDetails TFD    
 LEFT JOIN Loyalty..UserMap UM  WITH (NOLOCK) ON TFD.userKey = UM.UserId       
 WHERE TFD.userKey <> @UserKey     
    
UPDATE TFD     
SET     
 Isfollower = 1    
 FROM @TripFollowersDetails TFD    
 INNER JOIN Loyalty..UserFollowers UF  WITH (NOLOCK)  ON TFD.userKey = UF.UserId    
 WHERE UF.FollowerId = @UserKey    
  
DELETE FROM @TripFollowersDetails WHERE userKey = @UserKey  
  
DELETE FROM #Tripdetails WHERE userKey <> @UserKey /*need to delete friends data from this table(to create proper HashTag)*/  
  
  
/*=================  end of preparing data for trip follower details  ===================== */  
    
  
/*=================  preparing data for HashTag  ===================== */  
DECLARE @HastTagTable AS TABLE  
(  
HashTag varchar (50) DEFAULT NULL,  
HashType varchar(50) DEFAULT NULL  
)  

IF(select COUNT(1) from #Tripdetails) >0
BEGIN    
INSERT INTO @HastTagTable  
select COUNT(1), 'trips' from #Tripdetails  
END

IF(select COUNT(1) from #Tripdetails where TripStatusType = 'followed') >0
BEGIN
INSERT INTO @HastTagTable (HashTag,HashType)    
select COUNT(1), 'followed' from #Tripdetails where TripStatusType = 'followed'  
END

IF(select COUNT(1) from #Tripdetails where TripOrder = 3) >0
BEGIN
INSERT INTO @HastTagTable (HashTag,HashType)    
select COUNT(1), 'past trips' from #Tripdetails where TripOrder = 3  
END

INSERT INTO @HastTagTable (HashTag,HashType)    
select DISTINCT LOWER(ToCity), '4' from #Tripdetails  
  
  
/*=================  end of preparing data for HashTag  ===================== */  
  
/*=================  preparing data for friends Crowd of user  ===================== */  
  
  
DECLARE @FriendsCrowdTripdetailsFinal AS TABLE  
(  
Id int,  
FriendsUserKey INT,  
FriendsTripKey INT,  
TripFollowerUserKey INT,  
TripKey INT,  
FriendsName VARCHAR(100)DEFAULT NULL,  
CityName VARCHAR(100)DEFAULT NULL,  
FriendsDestinationImageURL VARCHAR(500)DEFAULT NULL,  
NoofFollower INT,  
TripFollowerUserImageURL VARCHAR(500)DEFAULT NULL,  
Privacytype INT,  
IsFollower INT,  
CrowdId INT  
  
)  


delete from #FriendsCrowdTripdetails where id <> 1  
delete from #FriendsCrowdTripdetails where  TripPrivacyType = 2 and InCrowd=0
  
INSERT INTO @FriendsCrowdTripdetailsFinal  
select ROW_NUMBER() OVER(PARTITION BY Td.CrowdId order by Td.CrowdId desc ) AS Id,Ft.userKey,FT.tripKey,T.userKey,T.tripKey, FT.UserName,FT.ToCity,Ft.DestinationImageURL,  
Ft.WatchersCount,  
CASE WHEN T.privacyType = 2 AND T.userKey != @UserKey THEN UM.BadgeUrl    
 ELSE CASE WHEN UM.UserImageData IS NOT NULL THEN '/user/image/' + CONVERT(VARCHAR, T.userKey) ELSE  ISNULL(UM.ImageURL,'') END END AS [TripFollowerUserImageURL],  
 T.privacyType, 0 as [IsFollower],Ft.CrowdId  
FROM Trip..TripDetails TD  
inner join #FriendsCrowdTripdetails FT WITH (NOLOCK) ON  Ft.CrowdId = TD.CrowdId  
inner join Trip..Trip T WITH (NOLOCK) ON  T.tripKey = Td.tripKey  
LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON T.userKey = UM.UserId    
  
UPDATE FT  
 SET IsFollower = 1  
FROM @FriendsCrowdTripdetailsFinal FT   
INNER JOIN (SELECT FriendsTripKey FROM @FriendsCrowdTripdetailsFinal WHERE TripFollowerUserKey =@UserKey) LT   
ON LT.FriendsTripKey = FT.FriendsTripKey  
  
  
UPDATE FTD  
set InCrowd = FT.IsFollower  
FROM #FriendsCrowdTripdetails FTD  
inner join @FriendsCrowdTripdetailsFinal FT ON FT.FriendsTripKey = FTD.tripKey and FT.FriendsUserKey = FTD.userKey  
/*=================  end of preparing data for friends Crowd of user  ===================== */  
  
  
SELECT * FROM #Tripdetails where userKey = @UserKey ORDER BY TripOrder ASC, tripstartdate ASC, tripKey ASC    
    
SELECT * FROM @TripFollowersDetails  WHERE Id = 1    
    
SELECT CASE WHEN HashType = '4' THEN REPLACE(HashTag,' ','') ELSE (HashTag + ' ' + HashType)  END AS [HashTagName], REPLACE(HashTag,' ','') as [HashTag],HashType FROM @HastTagTable  
  
SELECT * FROM #FriendsCrowdTripdetails order by tripKey  
  
SELECT * FROM @FriendsCrowdTripdetailsFinal order by FriendsTripKey  
  
END
GO
