SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[usp_GetTMUCaching]    
(            
 @FromIndex INT = 1,            
 @ToIndex INT = 1,          
 @loggedInUserKey INT=0  ,    
 @IsFilterApplied bit = 0,    
 @MinFollowed int = 0,    
 @MaxFollowed int = 0,    
 @MinSavings BIGINT = 0,    
 @maxSavings BIGINT= 0   ,    
 @MinBestPrice BIGINT=0,    
 @MaxBestPrice BIGINT=0           
)            
AS                
BEGIN           
    
    
           
    CREATE TABLE #CachingTMU          
    (          
  [tripKey] [int] NULL,          
  [tripsavedKey] [uniqueidentifier] NULL,          
  [triprequestkey] [int] NULL,          
  [userKey] [int] NULL,          
  [tripstartdate] [datetime] NULL,          
  [tripenddate] [datetime] NULL,          
  [tripfrom] [varchar](20) NULL,          
  [tripTo] [varchar](20) NULL,          
  [tripComponentType] [int] NULL,          
  [tripComponents] [varchar](100) NULL,          
  [rankRating] [float] NULL,          
  [tripAirsavings] [float] NULL,          
  [tripcarsavings] [float] NULL,          
  [triphotelsavings] [float] NULL,          
  [isOffer] [bit] NULL,          
  [OfferImageURL] [varchar](500) NULL,          
  [LinktoPage] [varchar](500) NULL,          
  [currentTotalPrice] [float] NULL,          
  [originalTotalPrice] [float] NULL,          
  [UserName] [varchar](200) NULL,          
  [FacebookUserUrl] [varchar](500) NULL,          
  [WatchersCount] [int] NULL,          
  [LikeCount] [int] NULL,          
  [IsWatcher] [bit] NULL,          
  [BookersCount] [int] NULL,          
  [TripPurchaseKey] [uniqueidentifier] NULL,          
  [FastestTrending] [float] NULL,          
  [TotalSavings] [float] NULL,          
--  [RowNumber] [int] NULL,          
  [Rating] [float] NULL,          
  [AirSegmentCabin] [varchar](50) NULL,          
  [CarClass] [varchar](100) NULL,          
  [AirRequestTypeName] [varchar](50) NULL,          
  [HotelRegionName] [varchar](100) NULL,          
  [TripScoring] [float] NULL,          
  [DestinationImageURL] [varchar](500) NULL,          
  [SavingsRanking] [float] NULL,          
  [Recency] [float] NULL,          
  [RecencyRanking] [float] NULL,          
  [Proximity] [int] NULL,          
  [ProximityRanking] [float] NULL,          
  [SocialRanking] [float] NULL,          
  [ComponentRanking] [float] NULL,          
  [FromCity] [varchar](100) NULL,          
  [FromState] [varchar](100) NULL,          
  [FromCountry] [varchar](100) NULL,          
  [ToCity] [varchar](100) NULL,          
  [ToState] [varchar](100) NULL,          
  [ToCountry] [varchar](100) NULL,          
  [tripPurchasedKey] [uniqueidentifier] NULL,          
  [tripStatusKey] [int] NULL,          
  [IsMyTrip] [bit] NULL,          
  [LatestDealAirPriceTotal] [float] NULL,          
  [LatestDealHotelPriceTotal] [float] NULL,          
  [LatestDealCarPriceTotal] [float] NULL,          
  [LatestDealAirPricePerPerson] [float] NULL,          
  [LatestDealHotelPricePerPerson] [float] NULL,          
  [LatestDealCarPricePerPerson] [float] NULL,          
  [IsBackFillData] [bit] NULL,          
  [IsZeroPriceAvailable] [bit] NULL,          
  [LatestAirLineCode] [varchar](30) NULL,          
  [LatestAirlineName] [varchar](64) NULL,          
  [LatestHotelChainCode] [varchar](20) NULL,          
  [HotelName] [varchar](100) NULL,          
  [CarVendorCode] [varchar](50) NULL,          
  [LatestCarVendorName] [varchar](30) NULL,          
  [CurrentHotelsComId] [varchar](10) NULL,          
  [LatestDealHotelPricePerPersonPerDay] [float] NULL,          
  [DateRanking] [float] NULL,          
  [NumberOfCurrentAirStops] [int] NULL,  --uncommented by pradeep for TFS 17817       
  [ExactCityMatchRanking] [float] NULL,          
  [LatestHotelRegionId] [int] NULL,          
  [CrowdId] [bigint] NULL,          
  [LatestDealAirSavingsTotal] [float] NULL,          
  [LatestDealCarSavingsTotal] [float] NULL,          
  [LatestDealHotelSavingsTotal] [float] NULL,          
  [LatestDealAirSavingsPerPerson] [float] NULL,          
  [LatestDealCarSavingsPerPerson] [float] NULL,          
  [LatestDealHotelSavingsPerPerson] [float] NULL,          
  [IsEventAvailable] [bit] NULL,          
  [EventKey] [bigint] NULL,          
  [TotalTripSavings] [float] NULL,          
  [TotalTripCount] [int] NULL ,        
  [AttendeeStatusKey] int default 0,    --added by pradeep      
  [TripPrivacyType] int default 0,  --added by Rohita    
  [MinFollowedTotal] int DEFAULT 0,    
  [MaxFollowedTotal] int DEFAULT(0),    
  [MinSavingsTotal] BIGINT DEFAULT(0),    
  [MaxSavingsTotal] BIGINT DEFAULT(0),    
  [MinBestPriceTotal] BIGINT DEFAULT(0),    
  [MaxBestPriceTotal] BIGINT DEFAULT(0),    
  [HotelNoOfNights] INT DEFAULT(1),  
  [NoOfStops] VARCHAR(20),  
  [InCrowd] INT DEFAULT(0)   ,
  [HotelId] BigInt DEFAULT(0)
 )         
     
 IF (@FromIndex < 21)    
BEGIN     
           
 INSERT INTO #CachingTMU          
 SELECT          
 tripKey          
 ,tripsavedKey          
 ,triprequestkey          
 ,userKey          
 ,tripstartdate          
 ,tripenddate          
 ,tripfrom          
 ,tripTo          
 ,tripComponentType          
 ,tripComponents          
 ,rankRating          
 ,tripAirsavings           
 ,tripcarsavings          
 ,triphotelsavings          
 ,isOffer          
 ,OfferImageURL          
 ,LinktoPage          
 ,currentTotalPrice          
 ,originalTotalPrice          
 ,UserName          
 ,FacebookUserUrl          
 ,WatchersCount          
 ,LikeCount          
 ,IsWatcher          
 ,BookersCount          
,TripPurchaseKey          
 ,FastestTrending          
 ,TotalSavings          
 --,RowNumber          
 ,Rating          
 ,AirSegmentCabin          
 ,CarClass          
 ,AirRequestTypeName          
 ,HotelRegionName          
 ,TripScoring          
 ,DestinationImageURL          
 ,SavingsRanking          
 ,Recency          
 ,RecencyRanking          
 ,Proximity          
 ,ProximityRanking          
 ,SocialRanking          
 ,ComponentRanking          
 ,FromCity          
 ,FromState          
 ,FromCountry          
 ,ToCity          
 ,ToState          
 ,ToCountry          
 ,tripPurchasedKey          
 ,tripStatusKey          
 ,IsMyTrip          
 ,LatestDealAirPriceTotal          
 ,LatestDealHotelPriceTotal          
 ,LatestDealCarPriceTotal          
 ,LatestDealAirPricePerPerson          
 ,LatestDealHotelPricePerPerson          
 ,LatestDealCarPricePerPerson          
 ,IsBackFillData          
 ,IsZeroPriceAvailable          
 ,LatestAirLineCode          
 ,LatestAirlineName          
 ,LatestHotelChainCode          
 ,HotelName          
 ,CarVendorCode          
 ,LatestCarVendorName          
 ,CurrentHotelsComId          
 ,LatestDealHotelPricePerPersonPerDay          
 ,DateRanking          
 ,NumberOfCurrentAirStops          
 ,ExactCityMatchRanking          
 ,LatestHotelRegionId          
 ,CrowdId          
 ,LatestDealAirSavingsTotal          
 ,LatestDealCarSavingsTotal          
 ,LatestDealHotelSavingsTotal          
 ,LatestDealAirSavingsPerPerson          
 ,LatestDealCarSavingsPerPerson          
 ,LatestDealHotelSavingsPerPerson          
 ,IsEventAvailable          
 ,EventKey          
 ,TotalTripSavings          
 ,TotalTripCount        
 ,0        
 ,TripPrivacyType    
 ,MinFollowedTotal    
 ,MaxFollowedTotal    
 ,MinSavingsTotal    
 ,MaxSavingsTotal    
 ,MinBestPriceTotal    
 ,MaxBestPriceTotal    
 ,HotelNoOfNights   
 ,NoOfStops  
 ,InCrowd  
 ,HotelId
      
 FROM CachingTMU WITH(NOLOCK)          
 --WHERE RowNumber BETWEEN @FromIndex AND @ToIndex          
           
 UPDATE #CachingTMU SET IsMyTrip = 1 WHERE userKey = @loggedInUserKey           
END        
 --IF @IsFilterApplied =1     
 --BEGIN         
 -- SELECT * FROM #CachingTMU CT where    
 -- CT.WatchersCount >= (CASE WHEN @MinFollowed>0 THEN @MinFollowed else 0 END)    
 -- AND CT.WatchersCount <= (CASE WHEN @MaxFollowed>0 THEN @MaxFollowed else 1000 END)    
 -- AND CT.MinSavingsTotal >=@MinSavings and CT.MaxSavingsTotal <=@maxSavings    
 -- AND CT.MinBestPriceTotal >=@MinBestPrice AND  CT.MaxBestPriceTotal<=@MaxBestPrice    
 --   End    
 --   Else    
 --   Begin    
 -- SELECT * FROM #CachingTMU              
 --   End    
     
 SELECT * FROM #CachingTMU            
             
 END
GO
