SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

--exec usp_GetTMU @cityCode=NULL,@siteKey=5,@cityType=N'To',@resultCount=20,@tripComponentType=0,@page=1,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@hotelClass=0,@loggedInUserKey=560799,@FromIndex=1,@ToIndex=20,@CarClass=N'',@AirClass=N'',@AirType=N'',@HashTag=N'',@TrendingPeople=N'0',@IsCrowdEvent=0,@IsSliderFilterApplied=1,@MinFollowed=0,@MaxFollowed=50,@MinSavings =0,@maxSavings=2000,@MinBestPrice=0,@MaxBestPrice=2000,@IsFilterApplied=0
-- EXEC Trip..usp_GetTMU @cityCode=NULL,@siteKey=5,@cityType=N'To',@resultCount=20,@tripComponentType=0,@page=16,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@hotelClass=0,@loggedInUserKey=560799,@FromIndex=1,@ToIndex=20,@CarClass=N'',@AirClass=N'',@AirType=N'',@HashTag='#Cancun,#4star'
--EXEC Trip..usp_GetTMU @cityCode=NULL,@siteKey=5,@cityType=N'To',@resultCount=20,@tripComponentType=0,@page=16,@tripKey=0,@startDate=NULL,@theme=0,@sortfield=N'',@friendOption=N'',@hotelClass=0,@loggedInUserKey=562416,@FromIndex=1,@ToIndex=20,@CarClass=N'',@AirClass=N'',@AirType=N'',@HashTag='#miami'            
Create PROC [dbo].[usp_GetTMU_Modified] 
(            
 @cityCode varchar(20) = NULL ,                                
 @cityType varchar ( 20) = 'From' ,                                
 @siteKey int ,                                 
 @resultCount int = 6 ,                                
 @tripComponentType INT = 0,                  
 @page INT   ,                
 @tripKey INT=0,            
 @startDate datetime=null ,            
 @theme int = 0,            
 @sortfield varchar(50) = '',            
 @friendOption VARCHAR(50) = '',            
 @hotelClass INT = 0,            
 @loggedInUserKey BIGINT = 0,            
 @FromIndex INT = 1,            
 @ToIndex INT = 1,            
 @CarClass VARCHAR(50) = '',            
 @AirClass VARCHAR(50) = '',            
 @AirType VARCHAR(50) = '',            
 @HashTag varchar(400) = '',
 @TrendingPeople int = 0,
 @IsCrowdEvent bit = 0,
 @IsSliderFilterApplied bit = 0,
 @MinFollowed int = 0,
 @MaxFollowed int = 0,
 @MinSavings BIGINT = 0,
 @maxSavings BIGINT= 0   ,
 @MinBestPrice BIGINT=0,
 @MaxBestPrice BIGINT=0  ,
 @IsFilterApplied bit = 0
)            
AS             
BEGIN            
 SET NOCOUNT ON;            
             
 -- ##### VARIABLE DELCARATION ##### --            
 DECLARE @RowNumber INT = 0            
 DECLARE @HotelRating1 FLOAT = -1            
 DECLARE @HotelRating2 FLOAT = -1            
 DECLARE @HotelRating3 FLOAT = -1 
 DECLARE @HotelRating4 FLOAT = -1 
 DECLARE @HotelRating5 FLOAT = -1            
 DECLARE @IsTypeFilterSelected BIT = 0            
 DECLARE @fromDate DATETIME            
 DECLARE @endDate DATETIME                
 DECLARE @TripCount INT = 0 
 
 DECLARE @MinFollowedTotal int = 0
 DECLARE @MaxFollowedTotal int = 0
 DECLARE @MinSavingsTotal BIGINT = 0
 DECLARE @MaxSavingsTotal BIGINT= 0 
 DECLARE @MinBestPriceTotal BIGINT=0
 DECLARE @MaxBestPriceTotal BIGINT=0 
            
             
             
 -- ##### TABLE DELCARATION ##### --             
 IF OBJECT_ID('tempdb..#PreferredCityList') IS NOT NULL            
  DROP TABLE #PreferredCityList            
             
 CREATE TABLE #PreferredCityList             
 (             
  CityCode VARCHAR(3),            
  CityName VARCHAR(100)             
 )            
            
 IF OBJECT_ID('tempdb..#NeighboringAirportLookup') IS NOT NULL            
  DROP TABLE #NeighboringAirportLookup            
              
 CREATE TABLE #NeighboringAirportLookup             
 (            
  neighborAirportCode VARCHAR(3)            
 )            
            
 IF OBJECT_ID('tempdb..#ConnectionsUserInfo') IS NOT NULL            
  DROP TABLE #ConnectionsUserInfo            
              
 CREATE TABLE #ConnectionsUserInfo            
 (            
  UserId BIGINT            
 )            
             
 IF OBJECT_ID('tempdb..#ConnectionsUserSaveTripInfo') IS NOT NULL            
  DROP TABLE #ConnectionsUserSaveTripInfo            
               
 CREATE TABLE #ConnectionsUserSaveTripInfo            
 (            
  tripKey INT,            
  tripSavedKey UNIQUEIDENTIFIER,            
  userKey BIGINT            
 )            
            
 IF OBJECT_ID('tempdb..#CalculateTripScoring') IS NOT NULL            
  DROP TABLE #CalculateTripScoring            
            
 CREATE TABLE #CalculateTripScoring             
 (            
  tripSavedKey UNIQUEIDENTIFIER,              
  Recency FLOAT,            
  Proximity FLOAT            
 )            
            
 IF OBJECT_ID('tempdb..#BookersCount') IS NOT NULL            
  DROP TABLE #BookersCount            
            
 CREATE TABLE #BookersCount             
 (            
  tripSavedKey UNIQUEIDENTIFIER,            
  BookersCount INT            
 )            
             
 IF OBJECT_ID('tempdb..#MostLikeCount') IS NOT NULL            
  DROP TABLE #MostLikeCount             
             
 CREATE TABLE #MostLikeCount             
 (            
  tripKey INT,            
  LikeCount INT            
 )            
            
 IF OBJECT_ID('tempdb..#WatchersCount') IS NOT NULL           
  DROP TABLE #WatchersCount            
            
 CREATE TABLE #WatchersCount             
 (            
  tripSavedKey UNIQUEIDENTIFIER,            
  WatchersCount INT,            
  CrowdId BIGINT      
 )            
             
    IF OBJECT_ID('tempdb..#FastestTrending') IS NOT NULL            
  DROP TABLE #FastestTrending            
             
 CREATE TABLE #FastestTrending             
 (            
  tripSavedKey UNIQUEIDENTIFIER,            
  FastestTrending FLOAT            
 )             
            
    IF OBJECT_ID('tempdb..#TripFollowersDetails') IS NOT NULL            
  DROP TABLE #TripFollowersDetails            
            
 CREATE TABLE #TripFollowersDetails             
 (            
  tripSavedKey UNIQUEIDENTIFIER,              
  userKey INT,           
  userName VARCHAR(200) DEFAULT NULL,            
  userImageURL VARCHAR(500)DEFAULT NULL,            
  tripKey INT DEFAULT(0)            
 )            
             
    IF OBJECT_ID('tempdb..#Tripdetails') IS NOT NULL            
  DROP TABLE #Tripdetails             
              
 CREATE TABLE #Tripdetails                           
 (                              
  -- TripdetailsKey int identity (1,1) ,                                
  tripKey int NULL,                                
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
  isOffer bit  NULL,                                
  OfferImageURL varchar(500) NULL,                
  LinktoPage varchar(500) NULL,              
  currentTotalPrice FLOAT NULL,              
  originalTotalPrice FLOAT NULL,              
  UserName VARCHAR(200),            
  FacebookUserUrl VARCHAR(500),            
  WatchersCount INT,            
  LikeCount INT ,            
  --ThemeType INT DEFAULT(0),            
  IsWatcher BIT DEFAULT(0),            
  BookersCount INT DEFAULT(0),            
  TripPurchaseKey uniqueidentifier NULL,            
  FastestTrending FLOAT NULL,            
  TotalSavings FLOAT,            
  RowNumber INT,            
  Rating FLOAT,            
  --AirSegmentCabinAbbrevation VARCHAR(50),            
  AirSegmentCabin VARCHAR(50),            
  --CarClassAbbrevation VARCHAR(100),            
  CarClass VARCHAR(100),            
  AirRequestTypeName VARCHAR(50),            
  --NoOfStops VARCHAR(20),            
  HotelRegionName VARCHAR(100),            
  TripScoring FLOAT,            
  DestinationImageURL VARCHAR(500),            
  SavingsRanking FLOAT DEFAULT(0),            
  Recency FLOAT DEFAULT(0),            
  RecencyRanking FLOAT DEFAULT(0),            
  Proximity INT DEFAULT(0),            
  ProximityRanking FLOAT DEFAULT(0),            
  SocialRanking FLOAT DEFAULT(0),            
  ComponentRanking FLOAT DEFAULT(0),            
  FromCity VARCHAR(100),            
  FromState VARCHAR(100),            
  FromCountry VARCHAR(100),            
  ToCity VARCHAR(100),            
  ToState VARCHAR(100),            
  ToCountry VARCHAR(100),            
  tripPurchasedKey uniqueidentifier NULL,            
  tripStatusKey INT DEFAULT(0),            
  IsMyTrip BIT DEFAULT(0),            
  LatestDealAirPriceTotal FLOAT DEFAULT(0),            
  LatestDealHotelPriceTotal FLOAT DEFAULT(0),            
  LatestDealCarPriceTotal FLOAT DEFAULT(0),            
  LatestDealAirPricePerPerson FLOAT DEFAULT(0),             
  LatestDealHotelPricePerPerson FLOAT DEFAULT(0),            
  LatestDealCarPricePerPerson FLOAT DEFAULT(0),              
  IsBackFillData BIT DEFAULT(0),            
  IsZeroPriceAvailable BIT DEFAULT(0),            
  LatestAirLineCode VARCHAR(30),            
  LatestAirlineName VARCHAR(64),              
  LatestHotelChainCode VARCHAR(20),              
  HotelName VARCHAR(100),            
  CarVendorCode VARCHAR(50),            
  LatestCarVendorName VARCHAR(30),            
  CurrentHotelsComId VARCHAR(10),            
  LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),            
  DateRanking FLOAT DEFAULT(0),            
  NumberOfCurrentAirStops INT DEFAULT(0),            
  ExactCityMatchRanking FLOAT DEFAULT(0),            
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
  AttendeeStatusKey INT DEFAULT(0), --added by pradeep          
  TripPrivacyType INT DEFAULT(0),
  MinFollowedTotal int DEFAULT(0),
  MaxFollowedTotal int DEFAULT(0),
  MinSavingsTotal BIGINT DEFAULT(0),
  MaxSavingsTotal BIGINT DEFAULT(0),
  MinBestPriceTotal BIGINT DEFAULT(0),
  MaxBestPriceTotal BIGINT DEFAULT(0),
  HotelNoOfNights INT DEFAULT(1),
  RecommendedHotelResponseKey UNIQUEIDENTIFIER,
  CarAverageTax FLOAT DEFAULT(0)
 )            
             
 IF OBJECT_ID('tempdb..#TripdetailsBackFill') IS NOT NULL            
  DROP TABLE #TripdetailsBackFill            
            
 CREATE TABLE #TripdetailsBackFill            
 (                                
  -- TripdetailsKey int identity (1,1) ,                                
  tripKey int NULL,                                
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
  isOffer bit  NULL,                                
  OfferImageURL varchar(500) NULL,                
  LinktoPage varchar(500) NULL,              
  currentTotalPrice FLOAT NULL,              
  originalTotalPrice FLOAT NULL,              
  UserName VARCHAR(200),            
  FacebookUserUrl VARCHAR(500),            
  WatchersCount INT,            
  LikeCount INT ,            
  --ThemeType INT DEFAULT(0),            
  IsWatcher BIT DEFAULT(0),            
  BookersCount INT DEFAULT(0),            
  TripPurchaseKey uniqueidentifier NULL,            
  FastestTrending FLOAT NULL,            
  TotalSavings FLOAT,            
  RowNumber INT,            
  Rating FLOAT,            
  --AirSegmentCabinAbbrevation VARCHAR(50),            
  AirSegmentCabin VARCHAR(50),            
  --CarClassAbbrevation VARCHAR(100),            
  CarClass VARCHAR(100),            
  AirRequestTypeName VARCHAR(50),            
  --NoOfStops VARCHAR(20),            
  HotelRegionName VARCHAR(100),            
  TripScoring FLOAT,            
  DestinationImageURL VARCHAR(500),            
  SavingsRanking FLOAT DEFAULT(0),            
  Recency FLOAT DEFAULT(0),            
  RecencyRanking FLOAT DEFAULT(0),            
  Proximity INT DEFAULT(0),            
  ProximityRanking FLOAT DEFAULT(0),            
  SocialRanking FLOAT DEFAULT(0),            
  ComponentRanking FLOAT DEFAULT(0),            
  FromCity VARCHAR(100),            
  FromState VARCHAR(100),            
  FromCountry VARCHAR(100),            
  ToCity VARCHAR(100),            
  ToState VARCHAR(100),            
  ToCountry VARCHAR(100),            
  tripPurchasedKey uniqueidentifier NULL,            
  tripStatusKey INT DEFAULT(0),            
  IsMyTrip BIT DEFAULT(0),            
  LatestDealAirPriceTotal FLOAT DEFAULT(0),            
  LatestDealHotelPriceTotal FLOAT DEFAULT(0),            
  LatestDealCarPriceTotal FLOAT DEFAULT(0),            
  LatestDealAirPricePerPerson FLOAT DEFAULT(0),            
  LatestDealHotelPricePerPerson FLOAT DEFAULT(0),            
  LatestDealCarPricePerPerson FLOAT DEFAULT(0),              
  IsBackFillData BIT DEFAULT(0),            
  IsZeroPriceAvailable BIT DEFAULT(0),            
  LatestAirLineCode VARCHAR(30),            
  LatestAirlineName VARCHAR(64),              
  LatestHotelChainCode VARCHAR(20),              
  HotelName VARCHAR(100),            
  CarVendorCode VARCHAR(50),            
  LatestCarVendorName VARCHAR(30),            
  CurrentHotelsComId VARCHAR(10),            
  LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),            
  DateRanking FLOAT DEFAULT(0),            
  NumberOfCurrentAirStops INT DEFAULT(0),            
  ExactCityMatchRanking FLOAT DEFAULT(0),          LatestHotelRegionId INT DEFAULT(0),            
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
  TotalTripCount INT DEFAULT(0),          
  AttendeeStatusKey INT DEFAULT(0), --added by pradeep 
  TripPrivacyType INT DEFAULT(0) ,
  MinFollowedTotal int DEFAULT(0),
  MaxFollowedTotal int DEFAULT(0),
  MinSavingsTotal BIGINT DEFAULT(0),
  MaxSavingsTotal BIGINT DEFAULT(0),
  MinBestPriceTotal BIGINT DEFAULT(0),
  MaxBestPriceTotal BIGINT DEFAULT(0),          
  HotelNoOfNights INT DEFAULT(1),
  RecommendedHotelResponseKey UNIQUEIDENTIFIER,
  CarAverageTax FLOAT DEFAULT(0) 
 )            
             
 IF OBJECT_ID('tempdb..#TripdetailsTemp') IS NOT NULL            
  DROP TABLE #TripdetailsTemp            
             
 Create Table #TripdetailsTemp             
 (                                
  -- TripdetailsKey int identity (1,1) ,                                
  tripKey int NULL,                                
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
  isOffer bit  NULL,                                
  OfferImageURL varchar(500) NULL,                
  LinktoPage varchar(500) NULL,              
  currentTotalPrice FLOAT NULL,              
  originalTotalPrice FLOAT NULL,              
  UserName VARCHAR(200),            
  FacebookUserUrl VARCHAR(500),            
  WatchersCount INT,            
  LikeCount INT ,            
  --ThemeType INT DEFAULT(0),            
  IsWatcher BIT DEFAULT(0),            
  BookersCount INT DEFAULT(0),            
  TripPurchaseKey uniqueidentifier NULL,            
  FastestTrending FLOAT NULL,            
  TotalSavings FLOAT,            
  RowNumber INT,            
  Rating FLOAT,            
  --AirSegmentCabinAbbrevation VARCHAR(50),            
  AirSegmentCabin VARCHAR(50),            
  --CarClassAbbrevation VARCHAR(100),            
  CarClass VARCHAR(100),            
  AirRequestTypeName VARCHAR(50),            
  --NoOfStops VARCHAR(20),            
  HotelRegionName VARCHAR(100),            
  TripScoring FLOAT,            
  DestinationImageURL VARCHAR(500),            
  SavingsRanking FLOAT DEFAULT(0),            
  Recency FLOAT DEFAULT(0),            
  RecencyRanking FLOAT DEFAULT(0),            
  Proximity INT DEFAULT(0),            
  ProximityRanking FLOAT DEFAULT(0),            
  SocialRanking FLOAT DEFAULT(0),            
  ComponentRanking FLOAT DEFAULT(0),            
  FromCity VARCHAR(100),            
  FromState VARCHAR(100),            
  FromCountry VARCHAR(100),            
  ToCity VARCHAR(100),            
  ToState VARCHAR(100),            
  ToCountry VARCHAR(100),                        
  tripPurchasedKey uniqueidentifier NULL,            
  tripStatusKey INT DEFAULT(0),            
  IsMyTrip BIT DEFAULT(0),            
  LatestDealAirPriceTotal FLOAT DEFAULT(0),            
  LatestDealHotelPriceTotal FLOAT DEFAULT(0),            
  LatestDealCarPriceTotal FLOAT DEFAULT(0),            
  LatestDealAirPricePerPerson FLOAT DEFAULT(0),            
  LatestDealHotelPricePerPerson FLOAT DEFAULT(0),            
  LatestDealCarPricePerPerson FLOAT DEFAULT(0),              
  IsBackFillData BIT DEFAULT(0),            
  IsZeroPriceAvailable BIT DEFAULT(0),            
  LatestAirLineCode VARCHAR(30),            
  LatestAirlineName VARCHAR(64),              
  LatestHotelChainCode VARCHAR(20),              
  HotelName VARCHAR(100),            
  CarVendorCode VARCHAR(50),            
  LatestCarVendorName VARCHAR(30),            
  CurrentHotelsComId VARCHAR(10),            
  LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),            
  DateRanking FLOAT DEFAULT(0),            
  NumberOfCurrentAirStops INT DEFAULT(0),            
  ExactCityMatchRanking FLOAT DEFAULT(0),            
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
  TotalTripCount INT DEFAULT(0),          
  AttendeeStatusKey INT DEFAULT(0), --added by pradeep                 
  TripPrivacyType INT DEFAULT(0),
  MinFollowedTotal int DEFAULT(0),
  MaxFollowedTotal int DEFAULT(0),
  MinSavingsTotal BIGINT DEFAULT(0),
  MaxSavingsTotal BIGINT DEFAULT(0),
  MinBestPriceTotal BIGINT DEFAULT(0),
  MaxBestPriceTotal BIGINT DEFAULT(0),
  HotelNoOfNights INT DEFAULT(1),
  RecommendedHotelResponseKey UNIQUEIDENTIFIER,
  CarAverageTax FLOAT DEFAULT(0) 
)            
            
            
 IF OBJECT_ID('tempdb..#TripdetailsFinal') IS NOT NULL        DROP TABLE #TripdetailsFinal            
             
 Create Table #TripdetailsFinal             
 (                                
  -- TripdetailsKey int identity (1,1) ,                                
  tripKey int NULL,                                
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
  isOffer bit  NULL,                                
  OfferImageURL varchar(500) NULL,                
  LinktoPage varchar(500) NULL,              
  currentTotalPrice FLOAT NULL,              
  originalTotalPrice FLOAT NULL,              
  UserName VARCHAR(200),            
  FacebookUserUrl VARCHAR(500),            
  WatchersCount INT,            
  LikeCount INT ,            
  --ThemeType INT DEFAULT(0),            
  IsWatcher BIT DEFAULT(0),            
  BookersCount INT DEFAULT(0),            
  TripPurchaseKey uniqueidentifier NULL,            
  FastestTrending FLOAT NULL,            
  TotalSavings FLOAT,            
  RowNumber INT,            
  Rating FLOAT,            
  --AirSegmentCabinAbbrevation VARCHAR(50),            
  AirSegmentCabin VARCHAR(50),            
  --CarClassAbbrevation VARCHAR(100),            
  CarClass VARCHAR(100),            
  AirRequestTypeName VARCHAR(50),            
  --NoOfStops VARCHAR(20),            
  HotelRegionName VARCHAR(100),            
  TripScoring FLOAT,            
  DestinationImageURL VARCHAR(500),            
  SavingsRanking FLOAT DEFAULT(0),            
  Recency FLOAT DEFAULT(0),            
  RecencyRanking FLOAT DEFAULT(0),            
  Proximity INT DEFAULT(0),            
  ProximityRanking FLOAT DEFAULT(0),            
  SocialRanking FLOAT DEFAULT(0),            
  ComponentRanking FLOAT DEFAULT(0),            
  FromCity VARCHAR(100),            
  FromState VARCHAR(100),            
  FromCountry VARCHAR(100),            
  ToCity VARCHAR(100),            
  ToState VARCHAR(100),            
  ToCountry VARCHAR(100),            
  tripPurchasedKey uniqueidentifier NULL,            
  tripStatusKey INT DEFAULT(0),            
  IsMyTrip BIT DEFAULT(0),            
  LatestDealAirPriceTotal FLOAT DEFAULT(0),            
  LatestDealHotelPriceTotal FLOAT DEFAULT(0),            
  LatestDealCarPriceTotal FLOAT DEFAULT(0),            
  LatestDealAirPricePerPerson FLOAT DEFAULT(0),            
  LatestDealHotelPricePerPerson FLOAT DEFAULT(0),            
  LatestDealCarPricePerPerson FLOAT DEFAULT(0),              
  IsBackFillData BIT DEFAULT(0),            
  IsZeroPriceAvailable BIT DEFAULT(0),            
  LatestAirLineCode VARCHAR(30),            
  LatestAirlineName VARCHAR(64),              
  LatestHotelChainCode VARCHAR(20),              
  HotelName VARCHAR(100),            
  CarVendorCode VARCHAR(50),            
  LatestCarVendorName VARCHAR(30),            
  CurrentHotelsComId VARCHAR(10),            
  LatestDealHotelPricePerPersonPerDay FLOAT DEFAULT(0),            
  DateRanking FLOAT DEFAULT(0),            
  NumberOfCurrentAirStops INT DEFAULT(0),            
  ExactCityMatchRanking FLOAT DEFAULT(0),            
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
  TotalTripCount INT DEFAULT(0),          
  AttendeeStatusKey INT DEFAULT(0), --added by pradeep               
  TripPrivacyType INT DEFAULT(0),
  MinFollowedTotal int DEFAULT(0),
  MaxFollowedTotal int DEFAULT(0),
  MinSavingsTotal BIGINT DEFAULT(0),
  MaxSavingsTotal BIGINT DEFAULT(0),
  MinBestPriceTotal BIGINT DEFAULT(0),
  MaxBestPriceTotal BIGINT DEFAULT(0),
  HotelNoOfNights INT DEFAULT(1),
  RecommendedHotelResponseKey UNIQUEIDENTIFIER,
  CarAverageTax FLOAT DEFAULT(0)   
 )            
             
              
 IF OBJECT_ID('tempdb..#UserTripCrowd') IS NOT NULL            
  DROP TABLE #UserTripCrowd            
            
 CREATE TABLE #UserTripCrowd            
 (            
  crowdKey BIGINT            
 )            
             
             
    IF OBJECT_ID('tempdb..#AttendeeTravelDetails') IS NOT NULL            
 DROP TABLE #AttendeeTravelDetails            
            
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
  AttendeeStatusKey INT DEFAULT(0) --added by pradeep               
 )            
             
             
             
-- ###################### COMMON CODE ######################## ---            
            
 /* DATE CODING COMMENTED SINCE CLIENT NOW WANTS NO DATE FILTER IRRESPECTIVE OF WHATEVER DATE SELECTED ...             
 IF @startDate IS NULL             
 BEGIN             
    SET @fromDate = CONVERT(DATETIME, '1753-01-01 00:00:00', 20)            
    SET @endDate = '9999-12-31' -- THIS IS MAX DATE             
 END            
 ELSE             
 BEGIN             
             
 /* CODE COMMENTED BECOZ CLIENT NOW WANTS 3 MONTHS WINDOW I.E.(+3 and -3) FROM DATE SELECTED BY USER FROM UI ..            
              
  SELECT @endDate = DATEADD(month, ((YEAR(@startDate) - 1900) * 12) + MONTH(@startDate), -1)                            
  SET @endDate = DATEADD(SECOND, 86399,@endDate) -- THIS WILL MAKE TIME UPTO 23:59:59            
 */            
  SET @fromDate = DATEADD(month,-2, DATEADD(dd,-(DAY(@startDate)-1),@startDate))            
  SET @endDate  = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@startDate)+3,0))            
               
 END                           
 */            
            
            
 /**Code added for implementing follow crowd logic based on crowd**/            
 IF ( @loggedInUserKey > 0 )            
    BEGIN            
     INSERT #UserTripCrowd            
     SELECT DISTINCT CrowdId FROM TripDetails TD WITH(NOLOCK) INNER JOIN Trip T WITH(NOLOCK) On (TD.tripKey=T.tripKey AND T.siteKey=@siteKey AND TD.userKey =@loggedInUserKey AND IsWatching=1 )            
     --WHERE TD.userKey =@loggedInUserKey AND IsWatching=1             
    END            
            
            
 IF @CarClass = 'C'            
 BEGIN             
  SET @CarClass = 'COMPACT'            
 END            
 ELSE IF @CarClass = 'E'            
 BEGIN             
  SET @CarClass = 'ECONOMY'            
 END            
 ELSE IF @CarClass = 'S'            
 BEGIN             
  SET @CarClass = 'STANDARD'            
 END            
 ELSE IF @CarClass = 'F'            
 BEGIN             
  SET @CarClass = 'FULL SIZE'            
 END            
 ELSE IF @CarClass = 'P'            
 BEGIN             
  SET @CarClass = 'PREMIUM'            
 END            
 ELSE IF @CarClass = 'X'            
 BEGIN             
SET @CarClass = 'SPECIAL'            
 END            
 ELSE IF @CarClass = 'M'            
 BEGIN             
  SET @CarClass = 'MINI VAN'            
 END            
 ELSE IF @CarClass = 'I'            
 BEGIN             
  SET @CarClass = 'INTERMEDIATE'            
 END            
 ELSE IF @CarClass = 'L'            
 BEGIN             
  SET @CarClass = 'LUXURY'            
 END            
             
             
 IF @AirType = 'OneWayTrip'            
 BEGIN            
  SET @AirType = 'ONEWAY'            
 END            
             
 -- RIGHT NOW IT IS SET TO BLANK BECAUSE THERE IS PROBLEM OF DATA COMING FROM UI WHERE STEVE NEEDS TO WORK ON IT...TILL THAT            
 -- KEEP BELOW CODE SET TO BLANK.             
 SET @CarClass = ''            
 SET @AirClass = ''            
 SET @AirType = ''            
            
             
             
/* CODE COMMENTED BECOZ CLIENT NOW WANTS 3 MONTHS WINDOW I.E.(+3 and -3) FROM DATE SELECTED BY USER FROM UI ..            
 HENCE BELOW CODE IS OF NO USE AS ITS CONDITION WILL BRING TODAY's DATE IF START DATE IS LESS THAN TODAY's DATE..             
             
 IF @startDate < GETDATE()            
 BEGIN             
  SET @startDate = CONVERT(DATETIME, GETDATE(), 20)            
 END                
*/            
             
            
             
/* ####################################################################################             
  STEP 1 STARTS :- FILTER DATA AND PREPARE RESULT SET              
#################################################################################### */            
             
 IF @sortfield <> ''            
 BEGIN              
             
  PRINT 'SORT FIELD'            
              
  -- THIS IS DONE TO AVOID FURTHER PROBLEM IN BELOW "IF" STATEMENTS IN SP ...            
  SET @friendOption = '' 
  DECLARE @FollowersCount INT
  select @FollowersCount = SplitFollowersCount  from TripSaved  WHERE tripSavedKey = '7EEB6A1D-57EB-4686-892D-891C3FA499D6'          
              
  INSERT INTO #Tripdetails            
  (             
   tripKey,            
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
   --ThemeType,             
   TripPurchaseKey,            
   BookersCount,             
   FastestTrending,            
   TotalSavings,            
   RowNumber,            
   Rating,            
   --AirSegmentCabinAbbrevation,            
   AirSegmentCabin,            
   --CarClassAbbrevation,            
   CarClass,            
   AirRequestTypeName,            
   --NoOfStops,            
   HotelRegionName,            
   DestinationImageURL,            
   FromCity ,            
   FromState ,            
   FromCountry ,            
   ToCity ,            
   ToState ,       
   ToCountry,            
   tripPurchasedKey,            
   tripStatusKey,            
   IsMyTrip,            
   LatestDealAirPriceTotal,            
   LatestDealHotelPriceTotal,            
   LatestDealCarPriceTotal,            
   LatestDealAirPricePerPerson,            
   LatestDealHotelPricePerPerson,            
   LatestDealCarPricePerPerson,            
   IsZeroPriceAvailable,            
   LatestAirLineCode ,            
   LatestAirlineName ,              
   LatestHotelChainCode ,              
   HotelName ,            
   CarVendorCode ,            
   LatestCarVendorName,            
   CurrentHotelsComId,            
   LatestDealHotelPricePerPersonPerDay,            
   NumberOfCurrentAirStops,            
   LatestHotelRegionId ,            
   CrowdId,            
   LatestDealAirSavingsTotal ,            
   LatestDealCarSavingsTotal ,            
   LatestDealHotelSavingsTotal,            
   LatestDealAirSavingsPerPerson ,              
   LatestDealCarSavingsPerPerson ,            
   LatestDealHotelSavingsPerPerson,          
   AttendeeStatusKey,
   TripPrivacyType,
   HotelNoOfNights,
   RecommendedHotelResponseKey,
   CarAverageTax           
  )                                
  SELECT              
   t1.tripKey,             
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
   CASE             
    WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)            
    ELSE            
     ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)            
    END as CurrentTotalPrice,              
   --CASE             
    --WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)  as OriginalTotalPrice,           
    --ELSE            
    -- ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)            
    --END as OriginalTotalPrice,                  
   
	CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   --26955 561945
			(SELECT distinct originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey)
		ELSE
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'            
	END AS UserName,
	CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			UM.BadgeUrl
		ELSE
			 ISNULL(UM.ImageURL,'')            
	END AS FacebookUserUrl,
	      
   ISNULL(TS.SplitFollowersCount,0) as WatchersCount,            
   0 as LikeCount,            
   --ISNULL(D.PrimaryTripType,0) as  ThemeType,            
   T1.tripPurchasedKey,            
   0 as BookersCount,            
   0 as FastestTrending,            
   CASE             
    WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)            
    ELSE               
     ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)                
    END as TotalSavings,            
   0,            
   HotelRating,             
   --'' -- AirSegmentCabinAbbrevation            
   TD.AirCabin,  -- AirSegmentCabin            
   --,'' -- CarClassAbbrevation            
   TD.CarClass, -- CarClass            
   TD.AirRequestTypeName, -- AirRequestTypeName            
   --TD., -- NoOfStops            
   TD.HotelRegionName,            
   T1.DestinationSmallImageURL,            
   TD.fromCityName,            
   CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,             
   CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,            
   TD.toCityName,            
   CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,            
   CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,            
   T1.tripPurchasedKey,            
   T1.tripStatusKey,            
   CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ...             
   CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,            
   CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,                 
   ISNULL(TD.latestDealCarPriceTotal,0) ,            
   ISNULL(TD.latestDealAirPricePerPerson,0) ,            
   ISNULL(TD.latestDealHotelPricePerPerson,0) ,                      
   ISNULL(TD.latestDealCarPricePerPerson,0) ,            
   CASE             
    WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
    WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
    WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
    WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
    WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
    WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'       
    WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
    ELSE 0                           
   END,            
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
   TD.crowdId,            
   ISNULL(TD.latestDealAirSavingsTotal,0),            
   ISNULL(TD.latestDealCarSavingsTotal,0),            
   ISNULL(TD.latestDealHotelSavingsTotal,0),            
   ISNULL(TD.LatestDealAirSavingsPerPerson,0) ,              
   ISNULL(TD.LatestDealCarSavingsPerPerson,0) ,            
   ISNULL(TD.LatestDealHotelSavingsPerPerson,0),          
   ISNULL(EA.AttendeeStatusKey,0),   -- added by pradeep          
   ISNULL(T1.PrivacyType,0),
   TD.HotelNoOfDays,
   TD.HotelResponseKey,
   CASE 
    WHEN TCR.minRateTax IS Not NULL THEN ROUND((TCR.minRateTax/TCR.NoOfDays), 2) ELSE 0              
   END             
                        
  FROM             
   TripDetails TD WITH (NOLOCK)                     
  INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey             
  INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                                                     
  LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId   
  --LEFT OUTER JOIN Vault..AirPreference AP WITH (NOLOCK) ON UI.userKey = AP.userKey
  --LEFT JOIN EventAttendees EA WITH (NOLOCK) ON T1.tripKey = EA.eventKey  --added by pradeep
  LEFT JOIN  Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON T1.tripKey = ATD.attendeeTripKey
  LEFT join EventAttendees EA WITH (NOLOCK) ON ATD.eventAttendeekey = EA.eventKey
    
  LEFT JOIN TripSaved TS WITH (NOLOCK) ON TD.tripSavedKey = TS.tripSavedKey
  LEFT OUTER JOIN TripSavedDeals  TSD ON TSD.tripKey = TD.tripKey
  LEFT OUTER JOIN TripCarResponse TCR ON TCR.carResponseKey = TSD.responseKey
  where  T1.tripStatusKey <> 17                      
  AND t1.tripKey <> @tripKey             
  AND T1.IsWatching = 1            
  AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....              
  --AND ((T1.privacyType = 1) OR (T1.userKey = @loggedInUserKey AND T1.privacyType = 2))  -- FOR PUBLIC AND PRIVATE PROFILE             


/* Gopal's Changes*/

UPDATE TD 
SET WatchersCount = (SELECT COUNT(distinct(t.userKey)) FROM Trip T WITH(NOLOCK) INNER  JOIN TripSaved TS WITH(NOLOCK) 
							ON T.tripSavedKey = TS.tripSavedKey WHERE T.IsWatching = 1 AND TS.crowdId = TD.CrowdId) 
FROM #Tripdetails TD

--SELECT originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey

UPDATE TD 
SET UserName = 'MIA ' + UM.BadgeName
FROM #Tripdetails TD
	-- Left Outer Join Vault..AirPreference WITH (NOLOCK) AP ON TD.UserKey = AP.UserKey
	LEFT OUTER JOIN Loyalty..UserMap UM ON TD.userKey = UM.UserId
WHERE TD.UserName IS NULL
/*  */            

              
 END              
 ELSE IF @page = 1 OR @page= 9 OR  @page = 11 OR @page = 12 OR @page = 15             
 /*            
  1 = HOME PAGE             
  9 = HOTEL SECTION LANDING PAGE             
  11 = FLIGHT SECTION LANDING PAGE            
  12 = CAR SECTION LANDING PAGE               
  15  = TRIP SUMMARY            
 */            
                       
 BEGIN             
             
 PRINT 'LAYER 2'            
             
 IF (@cityCode IS NOT NULL OR @cityCode <> '')            
 BEGIN            
   PRINT 'INSIDE LAYER 2'            
 -- GET NEIGHBOURHOOD AIRPORT DATA WHICH ARE WITHIN 100 MILES AND STORE IT IN TEMP TABLE ...              
   INSERT INTO #NeighboringAirportLookup            
   SELECT             
    neighborAirportCode             
   FROM             
    NeighboringAirportLookup WITH (NOLOCK)            
   WHERE             
    airportCode = @cityCode            
   AND             
    distanceInMiles <= 50            
                    
                
 -- SETTING HOTEL RATING WHICH IS THEN USED TO FILTER DATA AS PER HOTEL RATING SELECTED BY USER ....                 
   IF (@hotelClass = 5)            
   BEGIN               
    SET @HotelRating1 = 5            
    SET @HotelRating2 = 5            
    SET @HotelRating3 = 4.5  
    SET @HotelRating4 = 4.5 
    SET @HotelRating5 = 4.5           
   END             
   ELSE IF (@hotelClass = 4)            
   BEGIN             
    SET @HotelRating1 = 4            
    SET @HotelRating2 = 4.5            
    SET @HotelRating3 = 5  
    SET @HotelRating4 = 4.5 
    SET @HotelRating5 = 5              
   END              
   ELSE IF (@hotelClass = 3)            
   BEGIN             
    SET @HotelRating1 = 3            
    SET @HotelRating2 = 3.5            
    SET @HotelRating3 = 4   
    SET @HotelRating4 = 4.5 
    SET @HotelRating5 = 5             
   END              
            
 /* GET DATA AS PER OPTION SELECTED            
  ONLY ME = ONLY MY TRIPS             
  CONNECTIONS = PEOPLE WHICH ARE IN MY CONNECTIONS             
  CONNECTIONS AND FOLLOW = ME + PEOPLE WHICH ARE IN MY CONNECTIONS              
 */             
   IF (@friendOption = 'OnlyMe')            
   BEGIN             
                
    --PRINT 'Inside OnlyMe'            
                
    INSERT INTO #ConnectionsUserInfo            
    (UserId)            
    VALUES            
    (            
     @loggedInUserKey            
    )            
            
   END                
   ELSE IF (@friendOption = 'Connections')            
   BEGIN             
                
    --PRINT 'Inside Connections'            
            
    INSERT INTO #ConnectionsUserInfo             
    (            
     UserId            
    )            
    SELECT             
     UserId             
    FROM             
     Loyalty..UserMap WITH (NOLOCK)            
    WHERE             
     ParentId = @loggedInUserKey            
    AND             
     @loggedInUserKey <> 0            
            
            
   END             
   ELSE IF (@friendOption = 'ConnectionAndFollow')            
   BEGIN             
            
    --PRINT 'Inside ConnectionAndFollow'            
                
    INSERT INTO #ConnectionsUserInfo            
    (UserId)            
    VALUES            
    (            
     @loggedInUserKey            
    )            
            
                
    INSERT INTO #ConnectionsUserInfo (UserId)            
    SELECT UserId FROM Loyalty..UserMap WITH (NOLOCK)            
    WHERE ParentId = @loggedInUserKey             
    AND @loggedInUserKey <> 0            
            
   END            
            
 -- GET TRIPS AS PER OPTION SELECTED AND SAVE IT IN TEMP TABLE ....            
   INSERT INTO #ConnectionsUserSaveTripInfo            
   (            
    tripSavedKey,            
    tripKey,            
    userKey            
   )             
   SELECT DISTINCT             
    tripSavedKey,             
    tripKey,             
    userKey     
   FROM             
    Trip WITH (NOLOCK)            
   INNER JOIN             
    #ConnectionsUserInfo CUI ON Trip.userKey = CUI.UserId               
                 
   --PRINT 'FILTERED TMU '            
   INSERT INTO #Tripdetails            
   (             
    tripKey,            
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
    --ThemeType,             
    TripPurchaseKey,            
    BookersCount,             
    FastestTrending,            
    TotalSavings,            
    RowNumber,            
    Rating,            
    --AirSegmentCabinAbbrevation,            
    AirSegmentCabin,            
    --CarClassAbbrevation,            
    CarClass,            
    AirRequestTypeName,            
    --NoOfStops,            
    HotelRegionName,            
    DestinationImageURL,            
    FromCity ,            
    FromState ,            
    FromCountry ,            
    ToCity ,            
    ToState ,            
    ToCountry,            
    tripPurchasedKey,            
    tripStatusKey,            
    IsMyTrip,            
    LatestDealAirPriceTotal,            
    LatestDealHotelPriceTotal,            
    LatestDealCarPriceTotal,            
    LatestDealAirPricePerPerson,            
    LatestDealHotelPricePerPerson,            
    LatestDealCarPricePerPerson,            
    IsZeroPriceAvailable,            
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
    LatestDealCarSavingsPerPerson ,            
    LatestDealHotelSavingsPerPerson,          
    AttendeeStatusKey,   -- added by pradeep  
    TripPrivacyType,          
    HotelNoOfNights,                    
    RecommendedHotelResponseKey,
    CarAverageTax                  
   )                                
   SELECT              
    t1.tripKey,             
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
    CASE             
     WHEN TD.userKey = @loggedInUserKey  THEN              
      ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)            
     ELSE            
      ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)            
     END as CurrentTotalPrice,              
    --CASE             
     --WHEN TD.userKey = @loggedInUserKey  THEN              
      ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)  as OriginalTotalPrice,          
     --ELSE            
     -- ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)            
     --END as OriginalTotalPrice,  
     
     CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			(SELECT distinct originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey)
		ELSE
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'                        
	END AS UserName,
                     
    
   	CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			UM.BadgeUrl
		ELSE
			 ISNULL(UM.ImageURL,'')            
	END AS FacebookUserUrl,
	            
    ISNULL(TS.SplitFollowersCount,0) as WatchersCount,                
    0 as LikeCount,            
    --ISNULL(D.PrimaryTripType,0) as  ThemeType,            
    T1.tripPurchasedKey,            
    0 as BookersCount,            
    0 as FastestTrending,            
    CASE             
     WHEN TD.userKey = @loggedInUserKey  THEN              
      ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)            
     ELSE               
      ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)                
     END as TotalSavings,            
    0,            
    HotelRating,             
    --'' -- AirSegmentCabinAbbrevation            
    TD.AirCabin,  -- AirSegmentCabin            
    --,'' -- CarClassAbbrevation            
    TD.CarClass, -- CarClass            
    TD.AirRequestTypeName, -- AirRequestTypeName            
    --TD., -- NoOfStops            
    TD.HotelRegionName,            
    T1.DestinationSmallImageURL,            
    TD.fromCityName,            
    CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,               
    CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,            
    TD.toCityName,            
    CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,            
    CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,            
    T1.tripPurchasedKey,            
    T1.tripStatusKey,            
    CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ...             
    CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,            
    CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,                      
    ISNULL(TD.latestDealCarPriceTotal,0) ,            
 ISNULL(TD.latestDealAirPricePerPerson,0) ,            
    ISNULL(TD.LatestDealHotelPricePerPerson,0) ,                      
    ISNULL(TD.latestDealCarPricePerPerson,0) ,            
    CASE             
     WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
     WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
     WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'           
 
     WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
     WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
     WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'        
     WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
     ELSE 0            
    END,            
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
    Td.CrowdId,         
    ISNULL(TD.latestDealAirSavingsTotal,0),            
    ISNULL(TD.latestDealCarSavingsTotal,0),            
    ISNULL(TD.latestDealHotelSavingsTotal,0),            
    ISNULL(TD.LatestDealAirSavingsPerPerson,0) ,              
    ISNULL(TD.LatestDealCarSavingsPerPerson,0) ,            
    ISNULL(TD.LatestDealHotelSavingsPerPerson,0),          
    ISNULL(EA.attendeeStatusKey,0) ,
    ISNULL(T1.PrivacyType,0) ,
    HotelNoOfDays, 
    TD.HotelResponseKey,
    CASE 
		WHEN TCR.minRateTax IS Not NULL THEN ROUND((TCR.minRateTax/TCR.NoOfDays), 2) ELSE 0              
    END  
    --added by pradeep             
                    
   FROM             
    TripDetails TD WITH (NOLOCK)                     
   INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey             
   INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                                                   
   /*                
   REMOVED BELOW CONDITION SINCE NOW 1st LAYER WILL BRING ALL MIX RESULTS (AIR, CAR, HOTEL) ...            
   INNER JOIN dbo.udf_GetTripComponentType(@page,@typeFilter) FN_TRIPCOMPONENT ON T1.tripComponentType = FN_TRIPCOMPONENT.TripComponentType -- THIS IS DONE TO ADD SOME COMPONENT TYPE INTO TABLE.             
   */      
   INNER JOIN #NeighboringAirportLookup NAL ON (CASE WHEN @cityType = 'From' THEN TD.tripFrom ELSE TD.tripTo END) = NAL.neighborAirportCode                
   LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId  
   --LEFT JOIN Vault..AirPreference AP WITH (NOLOCK) ON UI.userKey = AP.userKey             
   --LEFT JOIN EventAttendees EA WITH (NOLOCK) ON TD.tripKey = EA.eventKey  --added by pradeep
   LEFT JOIN  Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON T1.tripKey = ATD.attendeeTripKey
   LEFT join EventAttendees EA WITH (NOLOCK) ON ATD.eventAttendeekey = EA.eventKey
      
   LEFT JOIN TripSaved TS WITH (NOLOCK) ON TD.tripSavedKey = TS.tripSavedKey          
   LEFT OUTER JOIN TripSavedDeals  TSD ON TSD.tripKey = TD.tripKey
   LEFT OUTER JOIN TripCarResponse TCR ON TCR.carResponseKey = TSD.responseKey   
   where  T1.tripStatusKey <> 17                      
   AND t1.tripKey <> @tripKey             
   AND T1.IsWatching = 1            
   /* DATE FILTERING REMOVED AS REQUIRED BY CLIENT ....            
   AND TD.tripStartDate BETWEEN @fromDate AND @endDate                    
   */            
   AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....              
   --AND ((T1.privacyType = 1) OR (T1.userKey = @loggedInUserKey AND T1.privacyType = 2))  -- FOR PUBLIC AND PRIVATE PROFILE             
               
   AND               
   (            
     TD.HotelRating =             
      CASE WHEN @HotelRating1 = -1 THEN HotelRating            
      ELSE @HotelRating1            
      END            
     OR            
     TD.HotelRating =             
      CASE WHEN @HotelRating2 = -1 THEN HotelRating            
      ELSE @HotelRating2            
      END            
     OR            
     TD.HotelRating =             
      CASE WHEN @HotelRating3 = -1 THEN HotelRating            
      ELSE @HotelRating3            
      END 
      OR            
     TD.HotelRating =             
      CASE WHEN @HotelRating4 = -1 THEN HotelRating            
      ELSE @HotelRating4            
      END 
      OR            
     TD.HotelRating =             
      CASE WHEN @HotelRating5 = -1 THEN HotelRating            
      ELSE @HotelRating5            
      END            
                  
   )               
   AND             
    UPPER(ISNULL(TD.CarClass,'')) =             
     CASE            
      WHEN @CarClass = '' THEN UPPER(ISNULL(TD.CarClass,''))            
      WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @CarClass            
     ELSE UPPER(ISNULL(TD.CarClass,''))            
     END            
                   
   AND            
    UPPER(ISNULL(TD.AirCabin,'')) =                 
     CASE             
      WHEN @AirClass = '' THEN UPPER(ISNULL(TD.AirCabin,''))            
      WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @AirClass            
     ELSE UPPER(ISNULL(TD.AirCabin,''))            
     END             
   AND            
    UPPER(ISNULL(TD.AirRequestTypeName,'')) =             
     CASE             
      WHEN @AirType = '' THEN UPPER(ISNULL(TD.AirRequestTypeName,''))            
      WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @AirType            
     ELSE UPPER(ISNULL(TD.AirRequestTypeName,''))            
     END                            
     
     
     /* Gopal's Changes */
UPDATE TD 
SET WatchersCount = (SELECT COUNT(distinct(t.userKey)) FROM Trip T WITH(NOLOCK) INNER  JOIN TripSaved TS WITH(NOLOCK) 
							ON T.tripSavedKey = TS.tripSavedKey WHERE T.IsWatching = 1 AND TS.crowdId = TD.CrowdId) 
FROM #Tripdetails TD

UPDATE TD 
SET UserName = 'MIA ' + UM.BadgeName
FROM #Tripdetails TD
	-- Left Outer Join Vault..AirPreference WITH (NOLOCK) AP ON TD.UserKey = AP.UserKey
	LEFT OUTER JOIN Loyalty..UserMap UM ON TD.userKey = UM.UserId
WHERE TD.UserName IS NULL

/*  */
            
   IF (@cityType = 'From')             
   BEGIN             
                
    IF (@page = 9)  -- /* 9 = HOTEL SECTION LANDING PAGE */            
    BEGIN            
     --PRINT 'Delete Hotel Only TMUs with same airport'            
     DELETE FROM #Tripdetails            
     WHERE tripComponentType = 4             
     AND tripfrom = @cityCode              
    END            
    ELSE IF (@page = 1 AND @tripComponentType = 4) -- /* Page = 1(HOME PAGE) | TripComponentType = 4 (HOTEL ONLY) */             
    BEGIN            
     PRINT 'Dont Delete anything'            
    END            
    ELSE            
    BEGIN             
     --PRINT 'Delete Hotel Only TMUs'            
     DELETE FROM #Tripdetails            
     WHERE tripComponentType = 4                
    END            
   END            
            
   IF (@friendOption <> '')            
   BEGIN             
            
     -- THIS DELETE STATEMENT IS USED TO DELETE RECORDS OF TRIPS WHERE USER KEY ARE NOT IN CONNECTIONS                
     DELETE FROM #Tripdetails             
     WHERE tripKey NOT IN (SELECT tripKey FROM #ConnectionsUserSaveTripInfo WHERE tripKey <> 0)            
                 
                 
    IF ( @loggedInUserKey > 0 )            
    BEGIN            
      /**Logic changed for watcher from save trip to crowd.**/            
      UPDATE TD             
      SET IsWatcher = 1             
      FROM #Tripdetails TD                 
      INNER JOIN #UserTripCrowd UC ON TD.CrowdId=UC.crowdKey            
      --INNER JOIN #ConnectionsUserSaveTripInfo CUS ON TD.tripsavedKey = CUS.tripSavedKey WHERE CUS.userKey = @loggedInUserKey            
    END              
                     
   END            
               
  END            
              
 END          
         
           
 ELSE IF (@page = 2) -- MY TRIPS             
 BEGIN             
  PRINT 'TRIP BOARD'            
              
  SET @friendOption = ''            
             
  INSERT INTO #Tripdetails            
  (             
   tripKey,            
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
   --ThemeType,             
   TripPurchaseKey,            
   BookersCount,             
   FastestTrending,            
   TotalSavings,            
   RowNumber,            
   Rating,            
   --AirSegmentCabinAbbrevation,            
   AirSegmentCabin,            
   --CarClassAbbrevation,            
   CarClass,            
   AirRequestTypeName,            
   --NoOfStops,            
   HotelRegionName,            
   DestinationImageURL,            
   FromCity ,            
   FromState ,            
   FromCountry ,            
   ToCity ,            
   ToState ,            
   ToCountry,            
   tripPurchasedKey,            
   tripStatusKey,            
   IsMyTrip,            
   LatestDealAirPriceTotal,            
   LatestDealHotelPriceTotal,            
   LatestDealCarPriceTotal,            
   LatestDealAirPricePerPerson,            
   LatestDealHotelPricePerPerson,            
   LatestDealCarPricePerPerson,            
   IsZeroPriceAvailable,            
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
   RecommendedHotelResponseKey,
   CarAverageTax                  
               
  )                         
  SELECT              
   t1.tripKey,             
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
   CASE             
    WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)            
    ELSE            
     ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)            
    END as CurrentTotalPrice,              
   --CASE             
   -- WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0) as OriginalTotalPrice,           
    --ELSE            
    -- ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)            
    --END as OriginalTotalPrice,  
    CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			(SELECT distinct originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey)
		ELSE
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'            
	END AS UserName,                    
   
   	CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			UM.BadgeUrl
		ELSE
			 ISNULL(UM.ImageURL,'')            
	END AS FacebookUserUrl,
	            
   ISNULL(TS.SplitFollowersCount,0) as WatchersCount,            
   0 as LikeCount,            
   --ISNULL(D.PrimaryTripType,0) as  ThemeType,            
   T1.tripPurchasedKey,            
   0 as BookersCount,            
   0 as FastestTrending,            
   CASE             
    WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)            
    ELSE               
     ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)                
    END as TotalSavings,            
   0,            
   HotelRating,             
   --'' -- AirSegmentCabinAbbrevation            
   TD.AirCabin,  -- AirSegmentCabin            
   --,'' -- CarClassAbbrevation            
   TD.CarClass, -- CarClass            
   TD.AirRequestTypeName, -- AirRequestTypeName            
   --TD., -- NoOfStops            
   TD.HotelRegionName,            
   T1.DestinationSmallImageURL,            
   TD.fromCityName,            
   CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,               
   CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,            
   TD.toCityName,            
   CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,            
   CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,            
   T1.tripPurchasedKey,            
   T1.tripStatusKey,            
   CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ...             
   CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,            
   CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,                      
   ISNULL(TD.latestDealCarPriceTotal,0) ,            
   ISNULL(TD.latestDealAirPricePerPerson,0) ,            
   ISNULL(TD.LatestDealHotelPricePerPerson,0) ,                      
   ISNULL(TD.latestDealCarPricePerPerson,0) ,            
   CASE             
    WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
    WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
    WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
    WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
    WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
        
    WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'         
    
    WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
    ELSE 0                
   END,            
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
   TD.HotelNoOfDays,
   TD.HotelResponseKey,
   CASE 
		WHEN TCR.minRateTax IS Not NULL THEN ROUND((TCR.minRateTax/TCR.NoOfDays), 2) ELSE 0              
    END          
    --added by pradeep                
                           
  FROM             
   TripDetails TD WITH (NOLOCK)                     
  INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey             
  INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                            
  LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId  
  --LEFT JOIN Vault..AirPreference AP WITH (NOLOCK) ON UI.userKey = AP.userKey         
  --LEFT JOIN EventAttendees EA WITH (NOLOCK) ON T1.tripKey = EA.eventKey  --added by pradeep
  LEFT JOIN  Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON T1.tripKey = ATD.attendeeTripKey 
  LEFT join EventAttendees EA WITH (NOLOCK) ON ATD.eventAttendeekey = EA.eventKey
   
  LEFT JOIN TripSaved TS WITH (NOLOCK) ON TD.tripSavedKey = TS.tripSavedKey             
  LEFT OUTER JOIN TripSavedDeals  TSD ON TSD.tripKey = TD.tripKey
  LEFT OUTER JOIN TripCarResponse TCR ON TCR.carResponseKey = TSD.responseKey     
  --where  T1.tripStatusKey <> 17                      
  where  T1.tripStatusKey not in ( 17,5 )  --added by pradeep for TFS #14132(if trip got cancelled then we dont need to show that in tripboad tmu)
  AND t1.tripKey <> @tripKey             
  AND T1.IsWatching = 1            
  AND TD.userKey = @loggedInUserKey            
  AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....              
   
 /* Gopal's Changes */
UPDATE TD 
SET WatchersCount = (SELECT COUNT(distinct(t.userKey)) FROM Trip T WITH(NOLOCK) INNER  JOIN TripSaved TS WITH(NOLOCK) 
							ON T.tripSavedKey = TS.tripSavedKey WHERE T.IsWatching = 1 AND TS.crowdId = TD.CrowdId) 
FROM #Tripdetails TD

UPDATE TD 
SET UserName = 'MIA ' + UM.BadgeName
FROM #Tripdetails TD
	-- Left Outer Join Vault..AirPreference WITH (NOLOCK) AP ON TD.UserKey = AP.UserKey
	LEFT OUTER JOIN Loyalty..UserMap UM ON TD.userKey = UM.UserId
WHERE TD.UserName IS NULL

/*   */                
             
 END             
 ELSE IF (@page = 16) -- Discover             
 BEGIN             
 
 --PRINT 'discover'            
              
  SET @friendOption = ''  

  Set @HashTag = LTRIM(@Hashtag)   
  Declare @compType int        
  Declare @OldcompType int --added by pradeep as per Zarir's requirement for Hash Tag's 
              
  DECLARE @HashTags TABLE            
  (HashTag varchar(400))            
         
  --Insert Into @HashTags(HashTag)            
  --Select rtrim(ltrim(string)) From dbo.ufn_DelimiterToTable(rtrim(ltrim(@HashTag)),',') 
  --Where String not in ('#air','#car','#hotel','#package')

  Insert Into @HashTags (HashTag)            
  Select rtrim(ltrim(CASE WHEN Charindex('#', string) != 1 Then '#' + string Else string End)) From dbo.ufn_DelimiterToTable(rtrim(ltrim(@HashTag)),',') 
  --Where String not in ('#air','#car','#hotel','#package')

--print 'hashtge is '+ @HashTag 
--select * from @HashTags

  If @HashTag is null
	SET @HashTag = ''
	Set @compType = @tripComponentType --copy tripcomponenttype value in temp variable to use in discover tripdetails
	set @OldcompType = 1
	
	IF CharIndex('#air', @HashTag) > 0
	BEGIN            
		SET @compType =  1 
		SET @HashTag = Replace(@HashTag,'#air','')
		
	END
	IF CharIndex('#car', @HashTag) > 0             
	BEGIN
		SET @compType = @compType + 2             
		SET @HashTag = Replace(@HashTag,'#car','')
		
	END
	IF CharIndex('#hotel', @HashTag) > 0   
	BEGIN         
		SET @compType = @compType + 4    
		SET @HashTag = Replace(@HashTag,'#hotel','')
		
	END
	IF CharIndex('#package', @HashTag) > 0             
	BEGIN
		SET @compType = 7
		SET @HashTag = Replace(@HashTag,'#package','')
		
	END            
	IF @compType = 0
	BEGIN
		SET @compType  = 7
		set @OldcompType = 0
    END 
    
 --print @OldcompType    
----------------- Added by Gopal - 20160111 -----------------------------------------------------------------------------------------------
DECLARE @HashTagTrips TABLE (HashTag varchar(400), tripKey INT) 
DECLARE @HashTagTrips1 TABLE (HashTag varchar(400), tripKey INT) 

DECLARE @HName VARCHAR(400)

INSERT INTO @HashTagTrips 
SELECT Distinct HashTag, TripKey From TripHashTagMapping WHERE HashTag = (SELECT TOP 1 HashTag FROM @HashTags)

INSERT INTO @HashTagTrips1 
SELECT Distinct HashTag, TripKey From TripHashTagMapping WHERE TripKey IN (SELECT TripKey FROM @HashTagTrips)

--Select * FROM @HashTags
--Select '@HashTagTrips1', * FROM @HashTagTrips1

DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR  SELECT HashTag FROM @HashTags 

OPEN db_cursor 
	FETCH NEXT FROM db_cursor INTO @HName 

	WHILE @@FETCH_STATUS = 0 
	BEGIN 

		   --PRINT @HName 
			--SELECT * FROM @HashTagTrips WHERE TripKey IN (SELECT TripKey FROM @HashTags WHERE HashTag = @HName) 
		   DELETE FROM @HashTagTrips1 WHERE TripKey NOT IN (SELECT TripKey FROM TripHashTagMapping WITH (NOLOCK) WHERE HashTag = @HName) 

	FETCH NEXT FROM db_cursor INTO @HName 
	END 

CLOSE db_cursor 
DEALLOCATE db_cursor 
--print @HashTag
---------------------------------------------------------------------------------------------------------------------------------------------------- 

  INSERT INTO #Tripdetails            
  (             
   tripKey,            
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
   --ThemeType,             
   TripPurchaseKey,            
   BookersCount,             
   FastestTrending,            
   TotalSavings,            
   RowNumber,            
   Rating,            
   --AirSegmentCabinAbbrevation,            
   AirSegmentCabin,            
   --CarClassAbbrevation,     
   CarClass,            
   AirRequestTypeName,            
   --NoOfStops,            
   HotelRegionName,            
   DestinationImageURL,            
   FromCity ,            
   FromState ,            
   FromCountry ,            
   ToCity ,            
   ToState ,            
   ToCountry,            
   tripPurchasedKey,            
   tripStatusKey,            
   IsMyTrip,            
   LatestDealAirPriceTotal,            
   LatestDealHotelPriceTotal,            
   LatestDealCarPriceTotal,            
   LatestDealAirPricePerPerson,            
   LatestDealHotelPricePerPerson,            
   LatestDealCarPricePerPerson,            
   IsZeroPriceAvailable,            
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
   RecommendedHotelResponseKey,
   CarAverageTax               
  )  
                                
  SELECT              
   t1.tripKey,             
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
   CASE             
    WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)            
    ELSE            
     ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)            
    END as CurrentTotalPrice,              
   --CASE             
   -- WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)   as OriginalTotalPrice,         
    --ELSE            
    -- ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)            
    --END as OriginalTotalPrice, 
   CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			(SELECT distinct originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey)
		ELSE
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'            
	END AS UserName,

   	CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			UM.BadgeUrl
		ELSE
			 ISNULL(UM.ImageURL,'')            
	END AS FacebookUserUrl,
	         
   ISNULL(TS.SplitFollowersCount,0) as WatchersCount,            
   0 as LikeCount,            
   --ISNULL(D.PrimaryTripType,0) as  ThemeType,            
   T1.tripPurchasedKey,            
   0 as BookersCount,            
   0 as FastestTrending,            
   CASE             
    WHEN TD.userKey = @loggedInUserKey  THEN              
     ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)            
    ELSE               
     ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)                
    END as TotalSavings,    
   0,            
   HotelRating,             
   --'' -- AirSegmentCabinAbbrevation            
   TD.AirCabin,  -- AirSegmentCabin            
   --,'' -- CarClassAbbrevation            
   TD.CarClass, -- CarClass            
   TD.AirRequestTypeName, -- AirRequestTypeName            
   --TD., -- NoOfStops            
   TD.HotelRegionName,            
   T1.DestinationSmallImageURL,            
   TD.fromCityName,            
   CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,               
   CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,            
   TD.toCityName,            
   CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,            
   CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,            
   T1.tripPurchasedKey,            
   T1.tripStatusKey,            
   CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ...             
   CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,            
   CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,                      
   ISNULL(TD.latestDealCarPriceTotal,0) ,            
   ISNULL(TD.latestDealAirPricePerPerson,0) ,            
   ISNULL(TD.LatestDealHotelPricePerPerson,0) ,                      
   ISNULL(TD.latestDealCarPricePerPerson,0) ,            
   CASE             
    WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
    WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
    WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
    WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
    WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
        
    WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'         
    
    WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
    ELSE 0                
   END,            
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
   TD.HotelNoOfDays,
   TD.HotelResponseKey,
   CASE 
		WHEN TCR.minRateTax IS Not NULL THEN ROUND((TCR.minRateTax/TCR.NoOfDays), 2) ELSE 0              
    END  
    --added by pradeep                
                           
  FROM             
   TripDetails TD WITH (NOLOCK)                     
  INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey  
  INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey  
  
  LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId    
  --LEFT JOIN Vault..AirPreference AP WITH (NOLOCK) ON UI.userKey = AP.userKey        
  --INNER JOIN dbo.TripHashTagMapping TH on TD.tripKey = TH.TripKey           
  --LEFT JOIN EventAttendees EA WITH (NOLOCK) ON T1.tripKey = EA.eventKey  --added by pradeep 
  LEFT JOIN  Trip..AttendeeTravelDetails ATD WITH (NOLOCK) ON T1.tripKey = ATD.attendeeTripKey
  LEFT join EventAttendees EA WITH (NOLOCK) ON ATD.eventAttendeekey = EA.eventKey
  LEFT JOIN TripSaved TS WITH (NOLOCK) ON TD.tripSavedKey = TS.tripSavedKey             
  LEFT OUTER JOIN TripSavedDeals  TSD ON TSD.tripKey = TD.tripKey
  LEFT OUTER JOIN TripCarResponse TCR ON TCR.carResponseKey = TSD.responseKey
  where  
  T1.tripStatusKey <> 17                      
  AND t1.tripKey <> @tripKey             
  AND T1.IsWatching = 1            
  --AND TD.userKey = @loggedInUserKey   
  --And TD.userKey = Case When @TrendingPeople > 0 Then @TrendingPeople Else TD.UserKey End         
  AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....              
  
---and T1.tripComponentType>= case when  @OldcompType =0 then 1 when @compType >0 and @compType <7 then @compType else @compType end --added by pradeep as zarir's requirment      
 AND T1.tripComponentType in (select TripComponentVal from [Trip].[dbo].[TripComponentLookUp]  where ComponentTypeKey = case when @OldcompType =0 then 0 else @compType end)
  AND 1 =	CASE WHEN @HashTag = '' THEN 1 ELSE  
		(
			SELECT top 1 1 FROM @HashTagTrips1 TH WHERE TD.tripKey = TH.TripKey 
				--AND TH.HashTag IN (SELECT CASE WHEN Charindex('#', HashTag) != 1 Then '#' + HashTag Else HashTag End From @HashTags)
		) 
		END		
  

  /* Gopal's Changes */
UPDATE TD 
SET WatchersCount = (SELECT COUNT(distinct(t.userKey)) FROM Trip T WITH(NOLOCK) INNER  JOIN TripSaved TS WITH(NOLOCK) 
							ON T.tripSavedKey = TS.tripSavedKey WHERE T.IsWatching = 1 AND TS.crowdId = TD.CrowdId) 
FROM #Tripdetails TD

UPDATE TD 
SET UserName = 'MIA ' + UM.BadgeName
FROM #Tripdetails TD
	-- Left Outer Join Vault..AirPreference WITH (NOLOCK) AP ON TD.UserKey = AP.UserKey
	LEFT OUTER JOIN Loyalty..UserMap UM ON TD.userKey = UM.UserId
WHERE TD.UserName IS NULL
/*  */                 

             
 END             
            
-- ################ COMMON DELETE STATEMENTS AFTER RESULT SET PREPARATION ################ --            
             
 /* BELOW DELETE STATEMENT IS COMMENTED BCOZ :- CLIENT WANTS THAT ALL TMU's SHOULD APPEAR IRRESPECTIVE             
    OF THEIR SAVINGS IN -VE ....                
 DELETE FROM @Tripdetails            
 WHERE TotalSavings <= 10            
 */            
 -- THIS DELETE STATEMENT IS IMPLEMENTED BCOZ :- TMU OF THOSE USER WHICH ARE LOGGED IN + HE IS WATCHER + HIS TMU IS PURCHAED i.e.(PURCHASED KEY IS NOT NULL) SHOULD BE DELETED FROM PROD MIX ...            
             
 IF (@page <> 2) /* 2 = MY TRIPS. MY TRIPS IS NOT IN EFFECT FOR BACKFILL DATA HENCE NO NEED TO PUT THIS "IF CONDITION" BELOW FOR BACKFILL ...            
        NOW CLIENT WANTS THAT PURCHASED TMU SHOWED BE SHOWN ON MY TRIP PAGE HENCE WE WONT'T DELETE PURCHAED TMU RECORDS FOR @page = 2*/                  
 BEGIN             
 --PRINT 'DELETE PURCHASED TMU 1'            
  DELETE             
  FROM #Tripdetails             
  WHERE             
   userKey = @loggedInUserKey            
  AND             
   tripPurchasedKey IS NOT NULL               
 END            
 -- THIS DELETE STATEMENT IS IMPLEMENTED BCOZ :- ZERO PRICE TMU's WILL NOT COME ....             
 DELETE             
 FROM #Tripdetails            
 WHERE IsZeroPriceAvailable = 1            
            
    
/* ************************************************************************************             
  STEP 1 ENDS :- FILTER DATA AND PREPARE RESULT SET              
************************************************************************************ */            
              
---- ################# BACK FILL DATA STARTS ################# ------              
 IF @page = 1 OR @page= 9 OR  @page = 11 OR @page = 12             
 /*            
  1 = HOME PAGE             
  9 = HOTEL SECTION LANDING PAGE             
  11 = FLIGHT SECTION LANDING PAGE            
  12 = CAR SECTION LANDING PAGE               
 */            
    
 BEGIN             
             
              
  IF ((@cityCode IS NULL OR @cityCode = '') AND @sortfield = '') -- THIS IS DONE FOR BACK FILL LOGIC ...             
                    -- IF SORT FIELD IS NOT BLANK THEN GLOBAL TMU's WILL BE CALLED AND HENCE NO NEED TO CALL BACKFILL LOGIC            
  BEGIN            
              
   PRINT 'BACK FILL DATA'            
            
  -- ######### INSERT PREFERRED CITY DATA ######### --             
              
            
            
   INSERT INTO #PreferredCityList               
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
            
               
   INSERT INTO #TripdetailsBackFill            
   (             
    tripKey,            
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
    --ThemeType,             
    TripPurchaseKey,            
    BookersCount,             
    FastestTrending,            
    TotalSavings,            
    RowNumber,            
    Rating,            
    --AirSegmentCabinAbbrevation,            
    AirSegmentCabin,            
   --CarClassAbbrevation,            
    CarClass,            
    AirRequestTypeName,            
    --NoOfStops,            
    HotelRegionName,            
    DestinationImageURL,            
    FromCity ,            
    FromState ,            
    FromCountry ,            
    ToCity ,            
    ToState ,            
    ToCountry,            
    tripPurchasedKey,            
    tripStatusKey,            
    IsMyTrip,            
    LatestDealAirPriceTotal,            
    LatestDealHotelPriceTotal,            
    LatestDealCarPriceTotal,            
    LatestDealAirPricePerPerson,            
    LatestDealHotelPricePerPerson,            
    LatestDealCarPricePerPerson,            
    IsZeroPriceAvailable,            
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
    LatestDealCarSavingsPerPerson ,            
    LatestDealHotelSavingsPerPerson,
    TripPrivacyType,
    HotelNoOfNights,
    RecommendedHotelResponseKey,
    CarAverageTax           
                    
   )                                
   SELECT              
    t1.tripKey,             
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
    CASE             
     WHEN TD.userKey = @loggedInUserKey  THEN              
      ISNULL(TD.latestDealAirPriceTotal,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPriceTotal,0)            
     ELSE            
      ISNULL(TD.latestDealAirPricePerPerson,0) + ISNULL(TD.latestDealCarPriceTotal,0) + ISNULL(TD.latestDealHotelPricePerPerson,0)            
     END as CurrentTotalPrice,              
    --CASE             
    -- WHEN TD.userKey = @loggedInUserKey  THEN              
      ISNULL(TD.originalTotalPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalTotalPriceHotel,0)  as OriginalTotalPrice,          
     --ELSE            
     -- ISNULL(TD.originalPerPersonPriceAir,0) + ISNULL(TD.originalTotalPriceCar,0) + ISNULL(TD.originalPerPersonPriceHotel,0)            
     --END as OriginalTotalPrice, 
     CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			(SELECT distinct originAirportCode + ' ' + UM.BadgeName FROM Vault..AirPreference WITH (NOLOCK) WHERE userKey = T1.userKey)
		ELSE
			UI.userFirstName + ' ' + SUBSTRING(UI.userLastName, 1, 1)  + '.'            
	END AS UserName,                 
    
    	CASE             
		WHEN T1.privacyType = 2 AND TD.userKey != @loggedInUserKey  THEN   
			UM.BadgeUrl
		ELSE
			 ISNULL(UM.ImageURL,'')            
	END AS FacebookUserUrl,
	      
    ISNULL(TS.SplitFollowersCount,0) as WatchersCount,            
    0 as LikeCount,            
    --ISNULL(D.PrimaryTripType,0) as  ThemeType,            
    T1.tripPurchasedKey,            
    0 as BookersCount,            
    0 as FastestTrending,            
    CASE             
     WHEN TD.userKey = @loggedInUserKey  THEN              
      ISNULL(TD.latestDealAirSavingsTotal,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsTotal,0)            
     ELSE               
      ISNULL(TD.latestDealAirSavingsPerPerson,0) + ISNULL(TD.latestDealCarSavingsTotal,0) + ISNULL(TD.latestDealHotelSavingsPerPerson,0)                
     END as TotalSavings,            
    0,            
    HotelRating,             
    --'' -- AirSegmentCabinAbbrevation            
    TD.AirCabin,  -- AirSegmentCabin            
    --,'' -- CarClassAbbrevation            
    TD.CarClass, -- CarClass            
    TD.AirRequestTypeName, -- AirRequestTypeName            
    --TD., -- NoOfStops            
   TD.HotelRegionName,            
    T1.DestinationSmallImageURL,            
    TD.fromCityName,            
    CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromStateCode ELSE '' END,               
    CASE WHEN TD.fromCountryCode = 'US' THEN TD.fromCountryCode ELSE TD.fromCountryName END,            
    TD.toCityName,            
    CASE WHEN TD.toCountryCode = 'US' THEN TD.toStateCode ELSE '' END,            
    CASE WHEN TD.toCountryCode = 'US' THEN TD.toCountryCode  ELSE TD.toCountryName END,            
    T1.tripPurchasedKey,            
    T1.tripStatusKey,            
    CASE WHEN TD.userKey = @loggedInUserKey THEN 1 ELSE 0 END, -- REQUIRE BY STEVE ...             
    CASE WHEN TD.userKey = @loggedInUserKey  THEN  ISNULL(TD.latestDealAirPriceTotal,0)ELSE ISNULL(TD.latestDealAirPricePerPerson,0) END ,            
    CASE WHEN TD.userKey = @loggedInUserKey  THEN ISNULL(TD.latestDealHotelPriceTotal,0) ELSE ISNULL(TD.latestDealHotelPricePerPerson,0) END ,                      
    ISNULL(TD.latestDealCarPriceTotal,0) ,            
    ISNULL(TD.latestDealAirPricePerPerson,0) ,            
    ISNULL(TD.LatestDealHotelPricePerPerson,0) ,                      
    ISNULL(TD.latestDealCarPricePerPerson,0) ,            
    CASE             
     WHEN T1.tripComponentType = 1 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 )THEN 1 -- 'Air'            
     WHEN T1.tripComponentType = 2 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 ) THEN 1 -- 'Car'            
     WHEN T1.tripComponentType = 3 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR  ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0) THEN 1 --  'Air,Car'            
     WHEN T1.tripComponentType = 4 AND (ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0 )THEN 1 -- 'Hotel'            
     WHEN T1.tripComponentType = 5 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Hotel'        
      
     WHEN T1.tripComponentType = 6 AND (ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Car,Hotel'        
       
     WHEN T1.tripComponentType = 7 AND (ISNULL(TD.latestDealAirPriceTotal,0) = 0 OR ISNULL(TD.latestDealAirPricePerPerson,0) = 0 OR ISNULL(TD.latestDealCarPriceTotal,0) = 0 OR ISNULL(TD.latestDealCarPricePerPerson,0) = 0 OR ISNULL(TD.latestDealHotelPriceTotal,0) = 0 OR ISNULL(TD.latestDealHotelPricePerPerson,0) = 0) THEN 1 -- 'Air,Car,Hotel'                
     ELSE 0            
    END,            
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
    Td.CrowdId,            
    ISNULL(TD.latestDealAirSavingsTotal,0),            
    ISNULL(TD.latestDealCarSavingsTotal,0),            
    ISNULL(TD.latestDealHotelSavingsTotal,0),            
    ISNULL(TD.LatestDealAirSavingsPerPerson,0) ,              
    ISNULL(TD.LatestDealCarSavingsPerPerson,0) ,            
    ISNULL(TD.LatestDealHotelSavingsPerPerson,0),
    ISNULL(T1.PrivacyType,0),
    TD.HotelNoOfDays,
    TD.HotelResponseKey,
    CASE 
		WHEN TCR.minRateTax IS Not NULL THEN ROUND((TCR.minRateTax/TCR.NoOfDays), 2) ELSE 0              
    END            
                    
   FROM             
    TripDetails TD WITH (NOLOCK)                     
   INNER JOIN Trip T1 WITH (NOLOCK) ON TD.tripKey = T1.tripKey             
   INNER JOIN Vault..[User] UI WITH (NOLOCK) ON TD.userKey = UI.userKey                   
   INNER JOIN #PreferredCityList PCL ON (CASE WHEN @cityType = 'From' THEN TD.tripFrom ELSE TD.tripTo END) = PCL.CityCode             
   LEFT JOIN Loyalty..UserMap UM WITH (NOLOCK) ON UI.userKey = UM.UserId 
   --LEFT JOIN Vault..AirPreference AP WITH (NOLOCK) ON UI.userKey = AP.userKey  
   LEFT JOIN TripSaved TS WITH (NOLOCK) ON TD.tripSavedKey = TS.tripSavedKey              
   LEFT OUTER JOIN TripSavedDeals  TSD ON TSD.tripKey = TD.tripKey
   LEFT OUTER JOIN TripCarResponse TCR ON TCR.carResponseKey = TSD.responseKey 
   where  T1.tripStatusKey <> 17      
   AND t1.tripKey <> @tripKey             
   AND T1.IsWatching = 1            
   /* DATE FILTERING REMOVED AS REQUIRED BY CLIENT ....            
   AND TD.tripStartDate BETWEEN @fromDate AND @endDate                    
   */            
   AND TD.tripStartDate > DATEADD(D,2, GetDate()) -- DOD STOPS BEFORE TWO DAYS OF TRIP START DATE ....              
   --AND ((T1.privacyType = 1) OR (T1.userKey = @loggedInUserKey AND T1.privacyType = 2))  -- FOR PUBLIC AND PRIVATE PROFILE             
               
   AND               
   (            
     TD.HotelRating =             
      CASE WHEN @HotelRating1 = -1 THEN HotelRating            
      ELSE @HotelRating1            
      END            
     OR            
     TD.HotelRating =             
      CASE WHEN @HotelRating2 = -1 THEN HotelRating            
      ELSE @HotelRating2            
      END            
     OR            
     TD.HotelRating =             
      CASE WHEN @HotelRating3 = -1 THEN HotelRating            
      ELSE @HotelRating3            
      END            
                  
   )               
   AND             
    UPPER(ISNULL(TD.CarClass,'')) =             
     CASE            
      WHEN @CarClass = '' THEN UPPER(ISNULL(TD.CarClass,''))            
      WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @CarClass            
     ELSE UPPER(ISNULL(TD.CarClass,''))            
     END            
                   
   AND            
    UPPER(ISNULL(TD.AirCabin,'')) =                 
     CASE             
      WHEN @AirClass = '' THEN UPPER(ISNULL(TD.AirCabin,''))            
      WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @AirClass            
     ELSE UPPER(ISNULL(TD.AirCabin,''))            
     END             
   AND            
    UPPER(ISNULL(TD.AirRequestTypeName,'')) =             
     CASE             
      WHEN @AirType = '' THEN UPPER(ISNULL(TD.AirRequestTypeName,''))            
      WHEN T1.tripComponentType  & @tripComponentType = @tripComponentType THEN @AirType            
     ELSE UPPER(ISNULL(TD.AirRequestTypeName,''))            
     END                            
              
              
-- ################ DELETE STATEMENTS AFTER BACK FILL RESULT SET PREPARATION ################ --            
                
    /* BELOW DELETE STATEMENT IS COMMENTED BCOZ :- CLIENT WANTS THAT ALL TMU's SHOULD APPEAR IRRESPECTIVE             
       OF THEIR SAVINGS IN -VE ....                
    DELETE FROM @TripdetailsBackFill            
    WHERE TotalSavings <= 10            
    */            
    -- THIS DELETE STATEMENT IS IMPLEMENTED BCOZ :- TMU OF THOSE USER WHICH ARE LOGGED IN + HE IS WATCHER + HIS TMU IS PURCHAED i.e.(PURCHASED KEY IS NOT NULL) SHOULD BE DELETED FROM PROD MIX ...            
    --PRINT 'DELETE PURCHASED TMU BACKFILL'            
                
    DELETE             
    FROM #TripdetailsBackFill             
    WHERE             
    userKey = @loggedInUserKey            
    AND             
    tripPurchasedKey IS NOT NULL            
                
              
    DELETE FROM #TripdetailsBackFill            
    WHERE IsZeroPriceAvailable = 1     
    
--UPDATE TD 
--SET UserName = 'MIA ' + UM.BadgeName
--FROM #TripdetailsBackFill TD
--	-- Left Outer Join Vault..AirPreference WITH (NOLOCK) AP ON TD.UserKey = AP.UserKey
--LEFT OUTER JOIN Loyalty..UserMap UM ON TD.userKey = UM.UserId
--WHERE TD.UserName IS NULL
           
              
    IF (@cityType = 'From')             
    BEGIN             
                 
     IF (@page = 9)  -- /* 9 = HOTEL SECTION LANDING PAGE */            
     BEGIN            
      --PRINT 'Delete Hotel Only TMUs with same airport'            
      DELETE FROM #TripdetailsBackFill            
      WHERE tripComponentType = 4             
      AND tripfrom = @cityCode              
     END            
    END            
              
                
    INSERT INTO #Tripdetails            
    SELECT * FROM #TripdetailsBackFill            
    WHERE tripKey IN (SELECT max(tripKey) FROM #TripdetailsBackFill GROUP BY tripTo)                 
                
                
  END              
             
 END            
 ---- ################# BACK FILL DATA ENDS ################# ------             
             
-- ################ COMMON UPDATE STATEMENTS AFTER ALL RESULT SET PREPARATION (GLOBAL, FILTERED, MY TRIPS, BACKFILL) ################ --            
            
-- REASON :- TO UPDATE ISWATCHING = TRUE OF TMU'S FOR LOGGED IN USER'S ...            
 IF (@friendOption = '')            
 BEGIN            
  IF (@loggedInUserKey > 0)            
  BEGIN            
                 
    UPDATE TD             
    SET IsWatcher = 1             
    FROM #Tripdetails TD            
    INNER JOIN #UserTripCrowd UC ON TD.CrowdId= UC.crowdKey             
    --INNER JOIN Trip T WITH (NOLOCK) on TD.tripsavedKey =T.tripSavedKey            
    --AND T.userKey = @loggedInUserKey             
    --AND T.IsWatching = 1            
              
               
   /*            
    BELOW STATEMENT TO UPDATE WHETHER PARTICULAR TRIP CONTAINS EVENTS OR NOT ... THIS FLAG IS REQUIRED            
    BY CLIENT ON TMU UI SIDE ....             
   */              
               
   -- GET TRIP KEY AND ATTENDEE KEY ...            
   INSERT INTO #AttendeeTravelDetails            
   SELECT             
    ATD.eventAttendeekey, attendeeTripKey             
   FROM             
    TripDetails TD                
   INNER JOIN             
    AttendeeTravelDetails ATD ON TD.tripKey = ATD.attendeeTripKey            
            
            
   -- GET TRIP KEY AND EVENT KEY FROM ATTENDEE KEY ...            
   INSERT INTO #EventTripMapping            
   SELECT              
    ATD.attendeeTripKey,            
    eventKey                
   FROM             
    EventAttendees            
   INNER JOIN             
    #AttendeeTravelDetails ATD ON EventAttendees.eventAttendeeKey = ATD.eventAttendeekey            
            
   -- GET CONSOLIDATED MAPPING OF TRIPKEY, EVENTKEY, ATTENDEE KEY, USER KEY ...            
   INSERT INTO #EventAttendees            
   SELECT             
    ETM.tripKey,               
    EA.eventKey,             
    EA.eventAttendeeKey,                 
    EA.userKey,            
    0,          
    EA.attendeeStatusKey  --added by pradeep                
   FROM             
    EventAttendees EA            
   INNER JOIN             
    #EventTripMapping ETM ON EA.eventKey = ETM.eventKey            
           
   UPDATE EA            
   SET EA.eventViewerShipType = EV.eventViewershipType            
   FROM #EventAttendees EA             
   INNER JOIN Events EV ON EA.eventKey = EV.eventKey            
               
               
   -- FOR PUBLIC OR PRIVATE EVENTS OF LOGGEDIN USER OR USERS PART OF THOSE EVENTS/CROWD ...             
   UPDATE TD            
   SET             
    IsEventAvailable = 1,            
    EventKey = EA.eventKey,          
    AttendeeStatusKey = EA.AttendeeStatusKey  -- added by pradeep           
           
   FROM #TripDetails TD            
   INNER JOIN #EventAttendees EA ON TD.tripKey = EA.tripKey            
	WHERE EA.userKey = @loggedInUserKey  
	

    /* COMMENTED BCOZ REQUIRES APPROVAL FROM CLIENT WHETHER PUBLIC EVENT TAG SHOULD BE SHOWN OR NOT ON TMU ....            
    -- FOR PUBLIC EVENTS ..                
   UPDATE TD            
   SET             
    IsEventAvailable = 1,            
    EventKey = EA.eventKey            
   FROM #TripDetails TD            
   INNER JOIN #EventAttendees EA ON TD.tripKey = EA.tripKey            
   WHERE EA.eventViewerShipType = 1            
    */            
                
              
  END              
 END             
             
---- 15 = TRIP SUMMARY PAGE ....              
 IF (@page = 15)            
 BEGIN            
              
  --- BELOW DELETE STATEMENT IS WRITTEN SO THAT NO TMU's HAVING SHARE OR CROWD BUTTON SHOULD COME ON TRIP SUMMARY PAGE...            
  --- ONLY TMU's HAVING FOLLOW BUTTON SHOULD COME ON TRIP SUMMARY PAGE .... (AS DISCUSSED WITH ASHA AND CLIENT)               
              
  DELETE FROM #Tripdetails             
  WHERE             
  (            
  IsWatcher = 1            
  OR IsMyTrip = 1            
  )            
             
 END            
             
---- 2 = MY TRIPS            
 IF (@page = 2)            
 BEGIN            
              
  -- THIS UPDATE STATEMENT IS IMPLEMENTED BCOZ TO SOLVE ISSUE OF TOTAL TRIP COUNT AND TOTAL TRIP SAVINGS             
  -- OF USER IN MY TRIP BOARD PAGE ... THIS WILL SUM UP ALL TRIPS OF THAT USER AND NOT JUST FIRST 20 TRIPS ..            
  print 'updating TMU for trip board'       
  UPDATE T               
  SET             
   TotalTripSavings = B.TotalTripSavings,                 
   TotalTripCount = B.TotalTripCount            
  FROM #Tripdetails T            
  INNER JOIN             
  (            
   SELECT             
    RowNumber,             
    SUM(ROUND(ABS(TotalSavings),0)) as TotalTripSavings,             
    COUNT(tripKey) as TotalTripCount            
   FROM             
    #Tripdetails            
   GROUP BY             
    RowNumber            
  ) B            
  ON T.RowNumber = B.RowNumber            
                
              
 END            
             
             
             
/* ####################################################################################             
  STEP 2 STARTS :- CALCULATION AND RANKING OF PREPARED RESULT SET           
#################################################################################### */            
             
-- ################## COMMON CODE FOR CALCULATION STARTS ##################             
             
-- CALCULATING LIKE COUNT ....            
              
 INSERT INTO #MostLikeCount             
 SELECT             
  TL.tripKey,             
  SUM(tripLike) as LikeCount             
 FROM             
  TripLike TL WITH (NOLOCK)            
 INNER JOIN             
  #Tripdetails TD ON TL.tripKey = TD.tripKey                
 GROUP BY             
  TL.tripKey              
            
-- UPDATING LIKE COUNT IN TEMP TABLE ....            
            
 UPDATE TD            
 SET             
  TD.LikeCount = MLC.LikeCount            
 FROM             
  #Tripdetails TD             
 INNER JOIN             
  #MostLikeCount MLC ON TD.tripKey = MLC.tripKey            
            
            
            
            
-- ************************* COMMON CODE FOR CALCULATION ENDS ************************* --             
            
 IF (@page <> 2 AND @page <> 15) -- 2 = MY TRIPS || 15 = TRIP SUMMARY PAGE ...            
 BEGIN             
             
 -- PRINT 'NOT MY TRIPS AND TRIP SUMMARY PAGE'              
-- INSERTING BOOKER'S COUNT ......              
  INSERT INTO #BookersCount            
  SELECT             
   TD.tripsavedKey,            
   COUNT(T.tripPurchasedKey)            
  FROM             
   #Tripdetails TD            
  INNER JOIN             
   Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey            
  GROUP BY             
   TD.tripSavedKey            
                
              
-- UPDATING BOOKER'S COUNT ......              
  UPDATE TD            
  SET             
   TD.BookersCount = BC.BookersCount            
  FROM             
   #Tripdetails TD             
  INNER JOIN             
   #BookersCount BC ON TD.tripsavedKey = BC.tripSavedKey            
              
              
-- CALCULATING AND INSERTING FASTEST TRENDING  ......                
  INSERT INTO #FastestTrending            
  (            
   tripSavedKey,            
   FastestTrending            
  )            
  SELECT             
   TD.tripsavedKey,               
   CASE             
    WHEN CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT ) = 0             
    THEN CAST(COUNT(T.tripKey) AS FLOAT) /  1            
    ELSE CAST(COUNT(T.tripKey) AS FLOAT) /  CAST( DATEDIFF(day,MIN(T.CreatedDate),GETDATE()) AS FLOAT )             
   END as FastestTrending               
  FROM #Tripdetails TD            
  INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey            
  where             
   T.siteKey =@siteKey             
  and             
   T.tripStatusKey <> 17            
  AND             
   T.IsWatching = 1                      
  Group by             
   TD.tripSavedKey            
            
       
                
-- UPDATING FASTEST TRENDING  ......                
            
    UPDATE TD            
    SET             
     TD.FastestTrending = FT.FastestTrending            
    FROM #Tripdetails TD             
    INNER JOIN #FastestTrending FT ON TD.tripsavedKey = FT.tripSavedKey            
                
                   
 END             
             
 IF (@page = 1 OR @page= 9 OR  @page = 11 OR @page = 12 OR @page = 16)            
 /*            
  1 = HOME PAGE             
  9 = HOTEL SECTION LANDING PAGE             
  11 = FLIGHT SECTION LANDING PAGE            
  12 = CAR SECTION LANDING PAGE               
 */            
 BEGIN            
     -- print 'final call of duty'         
-- CALCULATING AND INSERTING (RECENY AND PROXIMITY)               
  INSERT INTO #CalculateTripScoring            
  (            
   tripSavedKey ,               
   Recency ,            
   Proximity             
                
  )            
  SELECT             
   TD.tripsavedKey,               
   DATEDIFF(day,MAX(T.CreatedDate),GETDATE()) as Recency,            
   ABS(DATEDIFF(day,MIN(TD.tripstartdate), GETDATE())) as Proximity            
   FROM #Tripdetails TD            
   INNER JOIN Trip T WITH (NOLOCK) ON TD.tripKey = T.tripKey            
  where             
   T.siteKey =@siteKey             
  and             
   T.tripStatusKey <> 17            
  AND             
   T.IsWatching = 1                      
  Group by             
   TD.tripSavedKey            
               
-- UPDATING (RECENY AND PROXIMITY)               
  UPDATE TD            
  SET TD.Recency = CTS.Recency,            
   TD.Proximity = CTS.Proximity            
  FROM #Tripdetails TD             
  INNER JOIN #CalculateTripScoring CTS ON TD.tripsavedKey = CTS.tripSavedKey            
             
/*            
             
  UPDATE @Tripdetails            
  SET SavingsRanking =             
   CASE             
    WHEN ABS(( TotalSavings / originalTotalPrice) * 100) >= 25 THEN 10               
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 20 AND 24.99 THEN 8             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 17 AND 19.99 THEN 7             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 15 AND 16.99 THEN 6             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 12 AND 14.99 THEN 5             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 9 AND 11.99 THEN 4             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 6 AND 8.99 THEN 3             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 3 AND 5.99 THEN 2             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) BETWEEN 1 AND 2.99 THEN 1             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100)  BETWEEN 0 AND 0.99 THEN -5             
    WHEN ABS((TotalSavings / originalTotalPrice) * 100) < 0 THEN -10             
   END            
            
*/            
            
  UPDATE #Tripdetails            
  SET SavingsRanking =             
  CASE             
   WHEN originalTotalPrice = 0 THEN -5            
   WHEN (( TotalSavings / originalTotalPrice) * 100) >= 25 THEN 10               
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 20 AND 24.99 THEN 8             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 17 AND 19.99 THEN 7             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 15 AND 16.99 THEN 6             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 12 AND 14.99 THEN 5             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 9 AND 11.99 THEN 4             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 6 AND 8.99 THEN 3             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 3 AND 5.99 THEN 2             
   WHEN ((TotalSavings / originalTotalPrice) * 100) BETWEEN 1 AND 2.99 THEN 1             
   WHEN ((TotalSavings / originalTotalPrice) * 100)  BETWEEN 0 AND 0.99 THEN -5             
   WHEN ((TotalSavings / originalTotalPrice) * 100) < 0 THEN -10                
  END               
               
  UPDATE #Tripdetails            
  SET RecencyRanking =            
  CASE            
   WHEN Recency = 0 THEN 5            
   WHEN Recency = 1 THEN 4.5            
   WHEN Recency = 7 THEN 4            
   WHEN Recency BETWEEN 8 AND 14 THEN 3            
   WHEN Recency BETWEEN 13 AND 21 THEN 2            
   WHEN Recency BETWEEN 20 AND 45 THEN 1.5                
   ELSE 0            
  END             
              
                    
              
  UPDATE #Tripdetails            
  SET ProximityRanking =             
  CASE             
   WHEN Proximity BETWEEN 22 AND 42 THEN 5            
   WHEN Proximity  BETWEEN 14 AND 21 THEN 4            
   WHEN Proximity  BETWEEN 43 AND 90 THEN 3            
   WHEN Proximity  BETWEEN 90 AND 180 THEN 2            
   WHEN Proximity > 180   THEN 1            
   WHEN Proximity < 14   THEN 0            
  END            
            
                 
              
              
  /*            
   BELOW COMPONENT RANKING IS CALCULATED WHEN COMPONENT TYPE MATCHES THE EXACT COMPONENT FROM TRIP DETAILS ...            
   REASON :- CLIENT WANTS THAT EXACT TRIP COMPONENT DATA COMING FROM TMU FILTER SHOULD COME ON TOP ...            
   EXAMPLE :- ON FLIGHT LANDING PAGE, TRIP COMPONENT TPYE = 1 (AIR). NOW AIR ONLY TRIP SHOULD COME ON TOP.            
      AIR + HOTEL OR ANY OTHER MIX COMPONENT SHOULD COME AFTER AIR ONLY TMU'S . HENCE BELOW CODE IS WRITTEN             
      TO GIVE RANKING OF "20" FOR MATCHING COMPONENT (AIR ONLY) AND "10" (AIR + ANY COMPONENT) ....                  
  */     
      
  UPDATE TD             
   SET ComponentRanking = 50            
  FROM #Tripdetails AS TD            
   WHERE tripComponentType = @tripComponentType             
   /* BELOW LINE COMMENTED BCOZ CLIENT WANTS HOTEL RATING IN FILTER CRITERIA AND NOT IN SCORING ...             
    AND             
    (            
    TD.Rating =             
     CASE WHEN @HotelRating1 = -1 THEN Rating            
     ELSE @HotelRating1            
     END            
    OR            
    Rating =             
     CASE WHEN @HotelRating2 = -1 THEN Rating            
     ELSE @HotelRating2            
     END            
    )               
   */               
              
              
  UPDATE TD            
   SET ComponentRanking = 10            
  FROM #Tripdetails AS TD            
  WHERE             
   tripComponentType  & @tripComponentType = @tripComponentType            
  AND tripComponentType <> @tripComponentType -- THIS LINE IS WRITTEN SO THAT RANKING DOES NOT GET OVERWRITES FOR SAME COMPONENT TYPE...            
             -- EG :- AIR ONLY TMU'S IS GIVEN RANKING AS "20". NOW THIS UPDATE STATEMENT SHOULD NOT REPLACE             
             --   RANKING TO 10 FOR THOSE TMU'S WHO'S RANKING IS ALREADY GIVEN AS "20" IN ABOVE UPDATE STATEMENT.             
             --   HENCE DO NOT INCLUDE THOSE TRIP COMPONENT RESULTS HAVING (AIR ONLY) TMU'S             
             --   IN THIS UPDATE STATEMENT..  
      
  DELETE FROM #Tripdetails            
  WHERE ComponentRanking = 0     
      
            
   
  /* COMMENTED BCOZ CLIENT DOES NOT WANT DATE FILTER ....            
              
  UPDATE TD            
  SET DateRanking = 15            
  FROM @Tripdetails AS TD            
  WHERE MONTH (tripstartdate) = MONTH(@startDate)            
  AND YEAR(tripstartdate) = YEAR(@startDate)            
              
  */            
              
  UPDATE TD             
  SET ExactCityMatchRanking = 10             
  FROM #Tripdetails TD            
  WHERE (CASE WHEN @cityType = 'From' THEN TD.tripFrom ELSE TD.tripTo END) = @cityCode            
              
              
               
 END             
/*            
 THIS IS SPECIFICALLY DONE FOR CALULATING SOCIAL RANKING FOR BELOW PAGES ....             
*/             
 IF (@page = 1 OR @page= 9 OR  @page = 11 OR @page = 12 OR @page = 15 OR @page = 16)             
 /*            
  1 = HOME PAGE             
  9 = HOTEL SECTION LANDING PAGE             
  11 = FLIGHT SECTION LANDING PAGE            
  12 = CAR SECTION LANDING PAGE               
  15 = TRIP SUMMARY PAGE              
 */            
             
 BEGIN            
             
             
-- ######### FOR CALCUATING SOCIAL RANKING STARTS ####### --             
    -- print 'FOR CALCUATING SOCIAL RANKING STARTS'        
  SELECT             
   UserId             
  INTO             
   #tmpConnectionUserInfo             
  FROM             
   Loyalty..UserMap WITH (NOLOCK)               
  WHERE             
   ParentId = @loggedInUserKey            
  AND             
   @loggedInUserKey <> 0            
            
             
                
  IF (@loggedInUserKey <> 0)            
  BEGIN             
   INSERT INTO  #tmpConnectionUserInfo            
   (            
    UserId            
   )            
   VALUES            
   (            
    @loggedInUserKey            
   )            
  END            
             
-- ****************** FOR CALCUATING SOCIAL RANKING ENDS ****************** --             
             
 --PRINT 'CALCULATE SOCIAL RANKING '            
             
  UPDATE TD            
   SET SocialRanking =             
   CASE             
    WHEN TD.userKey = @loggedInUserKey THEN 10            
    WHEN TD.userKey = CUI.UserId THEN 8                 
    ELSE 0            
   END               
  FROM  #Tripdetails AS TD            
  INNER JOIN #tmpConnectionUserInfo CUI ON TD.userKey = CUI.UserId             
              
              
  UPDATE TD            
   SET SocialRanking = ISNULL(SocialRanking,0) +  3            
  FROM #Tripdetails AS TD            
  INNER JOIN TripSaved TS WITH(NOLOCK) ON TD.userKey = TS.userKey            
  AND TD.tripsavedKey = TS.tripSavedKey            
  WHERE TS.userKey <> 0              
             
              
              
              
  UPDATE #TripDetails             
  SET TripScoring = ISNULL(SavingsRanking,0) + ISNULL(RecencyRanking,0) + ISNULL(ProximityRanking,0) +             
       ISNULL(SocialRanking,0) + ISNULL(ComponentRanking,0) + ISNULL(DateRanking, 0) +             
       ISNULL(ExactCityMatchRanking,0)            
              
              
             
              
             
 END            
            
/* ************************************************************************************             
  STEP 2 ENDS :- CALCULATION AND RANKING OF PREPARED RESULT SET                
************************************************************************************ */            
              
             
/* ####################################################################################             
  STEP 3 STARTS :- SORTING AND ORDERING OF FINAL RESULT SET               
#################################################################################### */            
             
 IF (@page = 15) -- 15 = TRIP SUMMARY PAGE            
 BEGIN            
             
  INSERT INTO #TripdetailsTemp            
  SELECT TOP 2 * FROM #Tripdetails            
  ORDER BY TripScoring DESC, WatchersCount DESC                    
             
               
 END            
 ELSE             
 BEGIN            
             
  INSERT INTO #TripdetailsTemp            
  SELECT * FROM #Tripdetails            
  WHERE IsBackFillData = 0                
  ORDER BY               
  CASE WHEN (@page = 2) THEN tripstartdate END DESC,            
  CASE WHEN (@sortfield ='')THEN TripScoring END DESC,                   
  CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,                
  CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,                
  CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,               
  CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,            
  tripKey DESC             
              
  INSERT INTO #TripdetailsTemp            
  SELECT * FROM #Tripdetails            
  WHERE IsBackFillData = 1            
  ORDER BY        
  CASE WHEN (@page = 2) THEN tripstartdate END DESC,            
  CASE WHEN (@sortfield ='')THEN TripScoring END DESC,                   
  CASE WHEN (@sortfield ='Most Followed') THEN WatchersCount END DESC,                
  CASE WHEN (@sortfield ='Most Purchased') THEN BookersCount END DESC,                
  CASE WHEN (@sortfield ='Most Liked') THEN LikeCount END DESC,               
  CASE WHEN (@sortfield = 'Fastest Trending') THEN FastestTrending END DESC,            
  tripKey DESC             
             
 END            
             
 UPDATE #TripdetailsTemp            
 SET @RowNumber = RowNumber = @RowNumber + 1                 
            
            
            
 --INSERT INTO #TripdetailsFinal            
 --SELECT * FROM #TripdetailsTemp            
 --WHERE RowNumber BETWEEN @FromIndex AND @ToIndex              
  
	SELECT distinct(tripKey), WatchersCount,userKey,
	case when TD.userKey = @loggedInUserKey then 
	--(LatestDealAirSavingsTotal+LatestDealHotelSavingsTotal+LatestDealCarSavingsTotal) 
	CASE                       
      WHEN @tripComponentType = 1 THEN LatestDealAirSavingsTotal
      WHEN @tripComponentType = 2 THEN LatestDealCarSavingsTotal
      WHEN @tripComponentType = 3 THEN LatestDealAirSavingsTotal+LatestDealCarSavingsTotal
      WHEN @tripComponentType = 4 THEN LatestDealHotelSavingsTotal
      WHEN @tripComponentType = 5 THEN LatestDealAirSavingsTotal+LatestDealHotelSavingsTotal
      WHEN @tripComponentType = 6 THEN LatestDealHotelSavingsTotal+LatestDealCarSavingsTotal
      WHEN @tripComponentType = 7 or @tripComponentType = 0 THEN LatestDealAirSavingsTotal+LatestDealHotelSavingsTotal+LatestDealCarSavingsTotal
     END
	
	
	else 
	--(LatestDealAirSavingsPerPerson + LatestDealHotelSavingsPerPerson+ LatestDealCarSavingsPerPerson) 
	CASE                       
      WHEN @tripComponentType = 1 THEN LatestDealAirSavingsPerPerson
      WHEN @tripComponentType = 2 THEN LatestDealCarSavingsPerPerson
      WHEN @tripComponentType = 3 THEN LatestDealAirSavingsPerPerson+LatestDealCarSavingsPerPerson
      WHEN @tripComponentType = 4 THEN LatestDealHotelSavingsPerPerson
      WHEN @tripComponentType = 5 THEN LatestDealAirSavingsPerPerson+LatestDealHotelPricePerPerson
      WHEN @tripComponentType = 6 THEN LatestDealHotelSavingsPerPerson+LatestDealCarSavingsPerPerson
      WHEN @tripComponentType = 7 or @tripComponentType = 0 THEN LatestDealAirSavingsPerPerson+LatestDealHotelSavingsPerPerson+LatestDealCarSavingsPerPerson
     END
	
	
	end as [MostSavingsPrice],
	case when TD.userKey = @loggedInUserKey then 
	--(LatestDealAirPriceTotal+LatestDealHotelPriceTotal+LatestDealCarPriceTotal) 
	CASE                       
      WHEN @tripComponentType = 1 THEN LatestDealAirPriceTotal
      WHEN @tripComponentType = 2 THEN LatestDealCarPriceTotal
      WHEN @tripComponentType = 3 THEN LatestDealAirPriceTotal+LatestDealCarPriceTotal
      WHEN @tripComponentType = 4 THEN LatestDealHotelPriceTotal
      WHEN @tripComponentType = 5 THEN LatestDealAirPriceTotal+LatestDealHotelPriceTotal
      WHEN @tripComponentType = 6 THEN LatestDealHotelPriceTotal+LatestDealCarPriceTotal
      WHEN @tripComponentType = 7 or @tripComponentType = 0 THEN LatestDealAirPriceTotal+LatestDealHotelPriceTotal+LatestDealCarPriceTotal
     END
	else 
	--(LatestDealAirPricePerPerson + LatestDealHotelPricePerPerson+ LatestDealCarPricePerPerson) 
	CASE                       
      WHEN @tripComponentType = 1 THEN LatestDealAirPricePerPerson
      WHEN @tripComponentType = 2 THEN LatestDealCarPricePerPerson
      WHEN @tripComponentType = 3 THEN LatestDealAirPricePerPerson+LatestDealCarPricePerPerson
      WHEN @tripComponentType = 4 THEN LatestDealHotelPricePerPerson
      WHEN @tripComponentType = 5 THEN LatestDealAirPriceTotal+LatestDealHotelPricePerPerson
      WHEN @tripComponentType = 6 THEN LatestDealHotelPricePerPerson+LatestDealCarPricePerPerson
      WHEN @tripComponentType = 7 or @tripComponentType = 0 THEN LatestDealAirPricePerPerson+LatestDealHotelPricePerPerson+LatestDealCarPricePerPerson
     END
	end as [BestPrice]
	INTO #TempFilterDetails FROM #TripdetailsTemp TD           
	 
--select * from #TempFilterDetails where BestPrice >=@MinBestPrice 
	
	select @MinFollowedTotal= CEILING(MIN(WatchersCount)) from #TripdetailsTemp having CEILING(MIN(WatchersCount)) >0
	select @MaxFollowedTotal=  CEILING(MAX(WatchersCount)) from #TripdetailsTemp 

	select @MinSavingsTotal= CEILING(MIN(LatestDealAirSavingsTotal+LatestDealHotelSavingsTotal+LatestDealCarSavingsTotal)) from #TripdetailsTemp having CEILING(MIN(LatestDealAirSavingsTotal+LatestDealHotelSavingsTotal+LatestDealCarSavingsTotal)) >0
	select @MaxSavingsTotal= CEILING(MAX(LatestDealAirSavingsTotal+LatestDealHotelSavingsTotal+LatestDealCarSavingsTotal)) from #TripdetailsTemp
	
	select @MinBestPriceTotal= CEILING(MIN(LatestDealAirPriceTotal+LatestDealHotelPriceTotal+LatestDealCarPriceTotal)) from #TripdetailsTemp having CEILING(MIN(LatestDealAirPriceTotal+LatestDealHotelPriceTotal+LatestDealCarPriceTotal))>0
	select @MaxBestPriceTotal= CEILING(MAX(LatestDealAirPriceTotal+LatestDealHotelPriceTotal+LatestDealCarPriceTotal)) from #TripdetailsTemp	
   
   UPDATE #TripdetailsTemp            
   SET MaxFollowedTotal=@MaxFollowedTotal, MaxSavingsTotal=@MaxSavingsTotal, MaxBestPriceTotal=@MaxBestPriceTotal,MinFollowedTotal = @MinFollowedTotal, MinSavingsTotal=@MinSavingsTotal, MinBestPriceTotal=@MinBestPriceTotal
   
   
IF @IsSliderFilterApplied =1 or  @IsFilterApplied=1
BEGIN
--print 'inside filter zone'
	IF @IsSliderFilterApplied =1  and @IsFilterApplied=0
	BEGIN
		INSERT INTO #TripdetailsFinal            
			SELECT TD.* FROM #TripdetailsTemp  TD
			INNER JOIN #TempFilterDetails TF on TD.tripKey = TF.tripKey
			WHERE 
			TF.WatchersCount >= (CASE WHEN @MinFollowed>0 THEN @MinFollowed else 0 END)
			AND TF.WatchersCount <= (CASE WHEN @MaxFollowed>0 THEN @MaxFollowed else 1000 END)
			AND TF.MostSavingsPrice >=@MinSavings and TF.MostSavingsPrice <=@maxSavings
			AND TF.BestPrice >=@MinBestPrice AND  TF.BestPrice<=@MaxBestPrice
			--AND TD.RowNumber BETWEEN @FromIndex AND @ToIndex              
			order by WatchersCount desc


		SELECT DISTINCT 
		  TF.tripKey,                                
		  tripsavedKey,                                
		  triprequestkey,             
		  userKey,                               
		  tripstartdate,                                
		  tripenddate,                                
		  tripfrom,                                
		  tripTo,                                
		  tripComponentType ,                
		  tripComponents ,                                                  
		  rankRating ,                                
		  tripAirsavings,                                  
		  tripcarsavings,                                
		  triphotelsavings,                          
		  isOffer,                                
		  OfferImageURL,                
		  LinktoPage,              
		  currentTotalPrice,              
		  originalTotalPrice,              
		  UserName,            
		  FacebookUserUrl,            
		  WatchersCount,            
		  LikeCount,            
		  IsWatcher,            
		  BookersCount,            
		  TripPurchaseKey,            
		  FastestTrending,            
		  TotalSavings,                   
		  Rating ,            
		  AirSegmentCabin ,            
		  CarClass,            
		  AirRequestTypeName,            
		  HotelRegionName,            
		  TripScoring,            
		  DestinationImageURL,            
		  SavingsRanking,            
		  Recency,            
		  RecencyRanking,            
		  Proximity,            
		  ProximityRanking,            
		  SocialRanking,            
		  ComponentRanking,            
		  FromCity,            
		  FromState,            
		  FromCountry,            
		  ToCity,            
		  ToState,            
		  ToCountry,            
		  tripPurchasedKey,            
		  tripStatusKey,            
		  IsMyTrip,            
		  LatestDealAirPriceTotal,            
		  LatestDealHotelPriceTotal,            
		  LatestDealCarPriceTotal,            
		  LatestDealAirPricePerPerson,            
		  (Isnull(LatestDealHotelPricePerPerson,0)/isnull(HotelNoOfNights,1) - Isnull(TR.hotelTaxRate,0)/isnull(HotelNoOfNights,1)) As LatestDealHotelPricePerPerson,           
		  (LatestDealCarPricePerPerson - CarAverageTax) As LatestDealCarPricePerPerson,            
		  IsBackFillData,            
		  IsZeroPriceAvailable,            
		  LatestAirLineCode,            
		  LatestAirlineName,              
		  LatestHotelChainCode,              
		  HotelName,            
		  CarVendorCode,            
		  LatestCarVendorName,            
		  CurrentHotelsComId,            
		  LatestDealHotelPricePerPersonPerDay,            
		  DateRanking,            
		  NumberOfCurrentAirStops,            
		  ExactCityMatchRanking,            
		  LatestHotelRegionId,            
		  CrowdId,            
		  LatestDealAirSavingsTotal,            
		  LatestDealCarSavingsTotal,            
		  LatestDealHotelSavingsTotal,            
		  LatestDealAirSavingsPerPerson,              
		  LatestDealCarSavingsPerPerson,            
		  LatestDealHotelSavingsPerPerson,            
		  IsEventAvailable,            
		  EventKey,            
		  TotalTripSavings,            
		  TotalTripCount,          
		  AttendeeStatusKey,
		  TripPrivacyType,
		  MinFollowedTotal,
		  MaxFollowedTotal,
		  MinSavingsTotal ,
		  MaxSavingsTotal ,
		  MinBestPriceTotal ,
		  MaxBestPriceTotal 
				
		 FROM #TripdetailsFinal TF
		LEFT OUTER JOIN Trip..TripHotelResponse TR ON TR.hotelResponseKey = TF.RecommendedHotelResponseKey
		Where IsEventAvailable = (Case When @IsCrowdEvent = 1 Then 1 Else IsEventAvailable End) --Added to filter events crowd in discover page mobile
		and RowNumber BETWEEN @FromIndex AND @ToIndex 

	END

	ELSE
	BEGIN
--print 'inside friends filter'
		INSERT INTO #TripdetailsFinal            
		SELECT TD.* FROM #TripdetailsTemp  TD
		INNER JOIN #TempFilterDetails TF on TD.tripKey = TF.tripKey
		where TD.userKey in (select UserId From Loyalty..UserFollowers where FollowerId=@loggedInUserKey)
		and TF.WatchersCount >= (CASE WHEN @MinFollowed>0 THEN @MinFollowed else 0 END)
		AND TF.WatchersCount <= (CASE WHEN @MaxFollowed>0 THEN @MaxFollowed else 1000 END)
		AND TF.MostSavingsPrice >=@MinSavings and TF.MostSavingsPrice <=@maxSavings
		AND TF.BestPrice >=@MinBestPrice AND  TF.BestPrice<=@MaxBestPrice
		
		SELECT DISTINCT 
		  TF.tripKey,                                
		  tripsavedKey,                                
		  triprequestkey,             
		  userKey,                               
		  tripstartdate,                                
		  tripenddate,                                
		  tripfrom,                                
		  tripTo,                                
		  tripComponentType ,                
		  tripComponents ,                                                  
		  rankRating ,                                
		  tripAirsavings,                                  
		  tripcarsavings,                                
		  triphotelsavings,                          
		  isOffer,                                
		  OfferImageURL,                
		  LinktoPage,              
		  currentTotalPrice,              
		  originalTotalPrice,              
		  UserName,            
		  FacebookUserUrl,            
		  WatchersCount,            
		  LikeCount,            
		  IsWatcher,            
		  BookersCount,            
		  TripPurchaseKey,            
		  FastestTrending,            
		  TotalSavings,                 
		  Rating ,            
		  AirSegmentCabin ,            
		  CarClass,            
		  AirRequestTypeName,            
		  HotelRegionName,            
		  TripScoring,            
		  DestinationImageURL,            
		  SavingsRanking,            
		  Recency,            
		  RecencyRanking,            
		  Proximity,            
		  ProximityRanking,            
		  SocialRanking,            
		  ComponentRanking,            
		  FromCity,            
		  FromState,            
		  FromCountry,            
		  ToCity,            
		  ToState,            
		  ToCountry,            
		  tripPurchasedKey,            
		  tripStatusKey,            
		  IsMyTrip,            
		  LatestDealAirPriceTotal,            
		  LatestDealHotelPriceTotal,            
		  LatestDealCarPriceTotal,            
		  LatestDealAirPricePerPerson,            
		  (Isnull(LatestDealHotelPricePerPerson,0)/isnull(HotelNoOfNights,1) - Isnull(TR.hotelTaxRate,0)/isnull(HotelNoOfNights,1)) As LatestDealHotelPricePerPerson,           
		  LatestDealCarPricePerPerson,              
		  IsBackFillData,            
		  IsZeroPriceAvailable,            
		  LatestAirLineCode,            
		  LatestAirlineName,              
		  LatestHotelChainCode,              
		  HotelName,            
		  CarVendorCode,            
		  LatestCarVendorName,            
		  CurrentHotelsComId,            
		  LatestDealHotelPricePerPersonPerDay,            
		  DateRanking,            
		  NumberOfCurrentAirStops,            
		  ExactCityMatchRanking,            
		  LatestHotelRegionId,            
		  CrowdId,            
		  LatestDealAirSavingsTotal,            
		  LatestDealCarSavingsTotal,            
		  LatestDealHotelSavingsTotal,            
		  LatestDealAirSavingsPerPerson,              
		  LatestDealCarSavingsPerPerson,            
		  LatestDealHotelSavingsPerPerson,
		  IsEventAvailable,            
		  EventKey,            
		  TotalTripSavings,            
		  TotalTripCount,          
		  AttendeeStatusKey,
		  TripPrivacyType,
		  MinFollowedTotal,
		  MaxFollowedTotal,
		  MinSavingsTotal ,
		  MaxSavingsTotal ,
		  MinBestPriceTotal ,
		  MaxBestPriceTotal 		
		
		 FROM #TripdetailsFinal  TF
		 LEFT OUTER JOIN Trip..TripHotelResponse TR ON TR.hotelResponseKey = TF.RecommendedHotelResponseKey
		Where IsEventAvailable = (Case When @IsCrowdEvent = 1 Then 1 Else IsEventAvailable End) --Added to filter events crowd in discover page mobile
		and RowNumber BETWEEN @FromIndex AND @ToIndex 

	END
	
END

ELSE
BEGIN 
	 
     IF @PAGE = 2 
  BEGIN 
   --print 'inside page = 2'            
	select  tripKey,tripStartDate,tripStatusKey ,DATEDIFF(day,GETDATE(),tripStartDate) AS DiffDate,'0' as [Order],
	case when TripPurchaseKey is null then 0 else 1 end as [IsTripPurchased], WatchersCount
	into #TripMyaccountFilter from  #TripdetailsTemp order by tripStatusKey asc
	
	update  #TripMyaccountFilter  set [Order]= 
	(
		case 
		when IsTripPurchased=1 then 1  --BOOKDED
		when tripStatusKey=1 then 2  --PENDING
		when tripStatusKey=2 then 2 --ACTIVE
		else 3  --WHICH MEANS TRIP SAVED
		end
	)
	
	--added this table to update row number so that we can select only rows between range
	select ROW_NUMBER() over (order by [Order],DiffDate,tripstartdate,WatchersCount) as [RowNumber],* into #TripMyAccountOrderByFilter from #TripMyaccountFilter 

	INSERT INTO #TripdetailsFinal            
	SELECT * FROM #TripdetailsTemp  
	
	SELECT DISTINCT 
		  TF.tripKey,                                
		  tripsavedKey,                                
		  triprequestkey,             
		  userKey,                               
		  TF.tripstartdate,                                
		  tripenddate,                                
		  tripfrom,                                
		  tripTo,                                
		  tripComponentType ,                
		  tripComponents ,                                                  
		  rankRating ,                                
		  tripAirsavings,                                  
		  tripcarsavings,                                
		  triphotelsavings,                          
		  isOffer,                                
		  OfferImageURL,                
		  LinktoPage,              
		  currentTotalPrice,              
		  originalTotalPrice,              
		  UserName,            
		  FacebookUserUrl,            
		  TF.WatchersCount,            
		  LikeCount,            
		  IsWatcher,            
		  BookersCount,            
		  TripPurchaseKey,            
		  FastestTrending,            
		  TotalSavings,                   
		  Rating ,            
		  AirSegmentCabin ,            
		  CarClass,            
		  AirRequestTypeName,            
		  HotelRegionName,            
		  TripScoring,            
		  DestinationImageURL,            
		  SavingsRanking,            
		  Recency,            
		  RecencyRanking,            
		  Proximity,            
		  ProximityRanking,            
		  SocialRanking,            
		  ComponentRanking,            
		  FromCity,            
		  FromState,            
		  FromCountry,            
		  ToCity,            
		  ToState,            
		  ToCountry,            
		  tripPurchasedKey,            
		  TF.tripStatusKey,            
		  IsMyTrip,            
		  LatestDealAirPriceTotal,            
		  LatestDealHotelPriceTotal,            
		  LatestDealCarPriceTotal,            
		  LatestDealAirPricePerPerson,            
		  (Isnull(LatestDealHotelPricePerPerson,0)/isnull(HotelNoOfNights,1) - Isnull(TR.hotelTaxRate,0)/isnull(HotelNoOfNights,1)) As LatestDealHotelPricePerPerson,           
		  (LatestDealCarPricePerPerson - CarAverageTax) As LatestDealCarPricePerPerson,                            
		  IsBackFillData,            
		  IsZeroPriceAvailable,            
		  LatestAirLineCode,            
		  LatestAirlineName,              
		  LatestHotelChainCode,              
		  HotelName,            
		  CarVendorCode,            
		  LatestCarVendorName,            
		  CurrentHotelsComId,            
		  LatestDealHotelPricePerPersonPerDay,            
		  DateRanking,            
		  NumberOfCurrentAirStops,            
		  ExactCityMatchRanking,            
		  LatestHotelRegionId,            
		  CrowdId,            
		  LatestDealAirSavingsTotal,            
		  LatestDealCarSavingsTotal,            
		  LatestDealHotelSavingsTotal,            
		  LatestDealAirSavingsPerPerson,              
		  LatestDealCarSavingsPerPerson,            
		  LatestDealHotelSavingsPerPerson,            
		  IsEventAvailable,            
		  EventKey,            
		  TotalTripSavings,            
		  TotalTripCount,          
		  AttendeeStatusKey,
		  TripPrivacyType,
		  MinFollowedTotal,
		  MaxFollowedTotal,
		  MinSavingsTotal ,
		  MaxSavingsTotal ,
		  MinBestPriceTotal ,
		  MaxBestPriceTotal, 	
		  tm.[Order],tm.DiffDate 
	 FROM #TripdetailsFinal  TF
	INNER JOIN  #TripMyAccountOrderByFilter TM on tm.tripKey = TF.tripKey
    LEFT OUTER JOIN Trip..TripHotelResponse TR ON TR.hotelResponseKey = TF.RecommendedHotelResponseKey
	Where TF.IsEventAvailable = (Case When @IsCrowdEvent = 1 Then 1 Else TF.IsEventAvailable End) --Added to filter events crowd in discover page mobile
	and TM.RowNumber between @FromIndex AND @ToIndex
	ORDER BY tm.[Order],tm.DiffDate

  END
  ELSE
  BEGIN
	  
	  --print 'inside last else'
	INSERT INTO #TripdetailsFinal            
	SELECT * FROM #TripdetailsTemp            
	WHERE RowNumber BETWEEN @FromIndex AND @ToIndex
	  
	SELECT DISTINCT 
		  TF.tripKey,                                
		  tripsavedKey,                                
		  triprequestkey,             
		  userKey,                               
		  TF.tripstartdate,                                
		  tripenddate,                                
		  tripfrom,                                
		  tripTo,                                
		  tripComponentType ,                
		  tripComponents ,                                                  
		  rankRating ,                                
		  tripAirsavings,                                  
		  tripcarsavings,                                
		  triphotelsavings,                          
		  isOffer,                                
		  OfferImageURL,                
		  LinktoPage,              
		  currentTotalPrice,              
		  originalTotalPrice,              
		  UserName,            
		  FacebookUserUrl,            
		  TF.WatchersCount,            
		  LikeCount,            
		  IsWatcher,            
		  BookersCount,            
		  TripPurchaseKey,            
		  FastestTrending,            
		  TotalSavings,                     
		  Rating ,            
		  AirSegmentCabin ,            
		  CarClass,            
		  AirRequestTypeName,            
		  HotelRegionName,            
		  TripScoring,            
		  DestinationImageURL,            
		  SavingsRanking,            
		  Recency,            
		  RecencyRanking,            
		  Proximity,            
		  ProximityRanking,            
		  SocialRanking,            
		  ComponentRanking,            
		  FromCity,            
		  FromState,            
		  FromCountry,            
		  ToCity,            
		  ToState,            
		  ToCountry,            
		  tripPurchasedKey,            
		  TF.tripStatusKey,            
		  IsMyTrip,            
		  LatestDealAirPriceTotal,            
		  LatestDealHotelPriceTotal,            
		  LatestDealCarPriceTotal,            
		  LatestDealAirPricePerPerson,            
		  (Isnull(LatestDealHotelPricePerPerson,0)/isnull(HotelNoOfNights,1) - Isnull(TR.hotelTaxRate,0)/isnull(HotelNoOfNights,1)) As LatestDealHotelPricePerPerson,           
		  (LatestDealCarPricePerPerson - CarAverageTax) As LatestDealCarPricePerPerson,                
		  IsBackFillData,            
		  IsZeroPriceAvailable,            
		  LatestAirLineCode,            
		  LatestAirlineName,              
		  LatestHotelChainCode,              
		  HotelName,            
		  CarVendorCode,            
		  LatestCarVendorName,            
		  CurrentHotelsComId,            
		  LatestDealHotelPricePerPersonPerDay,            
		  DateRanking,            
		  NumberOfCurrentAirStops,            
		  ExactCityMatchRanking,            
		  LatestHotelRegionId,            
		  CrowdId,            
		  LatestDealAirSavingsTotal,            
		  LatestDealCarSavingsTotal,            
		  LatestDealHotelSavingsTotal,            
		  LatestDealAirSavingsPerPerson,              
		  LatestDealCarSavingsPerPerson,            
		  LatestDealHotelSavingsPerPerson,            
		  IsEventAvailable,            
		  EventKey,            
		  TotalTripSavings,            
		  TotalTripCount,          
		  AttendeeStatusKey,
		  TripPrivacyType,
		  MinFollowedTotal,
		  MaxFollowedTotal,
		  MinSavingsTotal ,
		  MaxSavingsTotal ,
		  MinBestPriceTotal ,
		  MaxBestPriceTotal 	
	
	FROM #TripdetailsFinal  TF
    LEFT OUTER JOIN Trip..TripHotelResponse TR ON TR.hotelResponseKey = TF.RecommendedHotelResponseKey
	Where IsEventAvailable = (Case When @IsCrowdEvent = 1 Then 1 Else IsEventAvailable End) --Added to filter events crowd in discover page mobile
	  
  END
END           

        
             
             
             
/* ************************************************************************************             
  STEP 3 ENDS :- SORTING AND ORDERING OF FINAL RESULT SET                   
************************************************************************************ */            
            
/*            
            
-- ######################################################################################################## --            
         /* TMU FOLLOWER DETAILS STARTS  */            
-- ######################################################################################################## --            
            
            
              
  INSERT INTO @TripFollowersDetails                
  (            
   tripSavedKey ,              
   userKey ,            
   userName ,            
   userImageURL            
  )            
  SELECT             
   T.tripSavedKey,                
   T.userKey,            
   NULL,            
   NULL                 
  FROM             
   Trip T WITH (NOLOCK)            
  INNER JOIN             
   @TripdetailsFinal TD ON T.tripSavedKey = TD.tripSavedKey                 
  GROUP BY             
   T.tripSavedKey, T.userKey             
                
              
  INSERT INTO @TripFollowersDetails            
  (            
   tripSavedKey ,              
   userKey ,            
   userName ,            
   userImageURL              
  )            
  SELECT             
   TS.tripSavedKey,               
   TS.userKey,            
   NULL,            
   NULL                
  FROM             
   TripSaved TS WITH (NOLOCK)            
  INNER JOIN             
@TripdetailsFinal TD ON TS.tripSavedKey = TD.tripsavedKey            
  WHERE             
   parentSaveTripKey IS NOT NULL            
            
              
  UPDATE TFD            
  SET             
   userName = U.userFirstName + ' ' + LEFT(U.userLastName, 1)            
  FROM             
   @TripFollowersDetails TFD            
  INNER JOIN             
   vault..[User] U WITH(NOLOCK) ON TFD.userKey = U.userKey            
              
              
  UPDATE TFD            
  SET             
   userImageURL = UM.ImageURL             
  FROM             
   @TripFollowersDetails TFD            
  LEFT JOIN             
   Loyalty..UserMap UM WITH(NOLOCK) ON TFD.userKey = UM.UserId            
                      
              
              
              
  SELECT * FROM @TripFollowersDetails            
              
            
-- ******************************************************************************************************** --            
         /* TMU FOLLOWER DETAILS ENDS */            
-- ******************************************************************************************************** --            
*/            
             
END
GO
