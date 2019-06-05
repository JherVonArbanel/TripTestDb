SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--USP_GetSaveMerchandiseTrip 'DFW','From' ,5,6,0,1  
--exec USP_GetSaveMerchandiseTrip 'MIA','To' ,5,9,0,1,0  
--exec USP_GetSaveMerchandiseTrip @cityCode=N'',@siteKey=1,@cityType=N'From',@resultCount=0,@tripComponentType=2,@page=12,@tripKey=0
CREATE Procedure [dbo].[USP_GetSaveMerchandiseTrip] (                    
--DECLARE
@cityCode varchar(20) = NULL ,                    
@cityType varchar ( 20) = 'From' ,                    
@siteKey int ,                     
@resultCount int = 6 ,                    
@tripComponentType INT = 0,      
@page INT   ,    
@tripKey INT=0    
) AS                     
BEGIN                     

--	SELECT @cityCode=N'',@siteKey=1,@cityType=N'From',@resultCount=0,@tripComponentType=2,@page=12,@tripKey=0
	                     
	 IF @cityCode = ''                    
	 BEGIN                    
	  SET @cityCode = NULL                    
	 END                     
	                     
	                     
	 --DECLARE #tripdetails AS TABLE   
	 Create table #TripDetails                   
	 (                    
	  TripdetailsKey int identity (1,1) ,                    
	  tripKey int NULL,                    
	  tripsavedKey uniqueidentifier NULL ,                    
	  triprequestkey int NULL ,                    
	  tripstartdate datetime NULL ,                    
	  tripenddate datetime NULL ,                    
	  tripfrom varchar(20) NULL ,                    
	  tripTo varchar(20) NULL ,                    
	  tripComponentType int NULL ,    
	  tripComponents varchar(100) NULL ,                                      
	  rankRating int NULL ,                    
	  tripAirsavings float NULL ,                      
	  tripcarsavings float NULL ,                    
	  triphotelsavings float NULL,                    
	  isOffer bit  NULL,                    
	  OfferImageURL varchar(500) NULL,    
	  LinktoPage varchar(500) NULL,  
	  currentTotalPrice FLOAT NULL,  
	  UserName VARCHAR(200),
	  FacebookUserUrl VARCHAR(500)  
	 )                    
	                     
	 DECLARE @OfferDetails AS TABLE                     
	 (                    
	  OfferdetailsKey int  ,                    
	  tripKey int NULL,                    
	  tripsavedKey uniqueidentifier NULL ,                    
	  triprequestkey int NULL ,                    
	  tripstartdate datetime NULL ,                    
	  tripenddate datetime NULL ,                    
	  tripfrom varchar(20) NULL ,                    
	  tripTo varchar(20) NULL ,                    
	  tripComponentType int NULL ,        
	  tripComponents varchar(100) NULL ,                     
	  rankRating int NULL ,                    
	  tripAirsavings float NULL ,                      
	  tripcarsavings float NULL ,                    
	  triphotelsavings float NULL,                    
	  isOffer bit  NULL ,                    
	  OfferImageURL varchar(500) NULL,    
	  LinktoPage varchar(500) NULL,  
	  currentTotalPrice FLOAT NULL,  
	  UserName VARCHAR(200),
	  FacebookUserUrl VARCHAR(500)                                        
	  
	 )                    
	                  
	 DECLARE @DestinationImages AS TABLE                  
	 (                  
	  DestinationImageId int identity(1,1),                  
	  ImageURL varchar(500)                  
	 )            
	             
	 DECLARE @TripHotelGroup  as TABLE            
	 (            
	 Id INT IDENTITY(1,1),            
	 HotelGroupId INT,            
	 TripTo1 VARCHAR(10),            
	 URL VARCHAR(200)            
	             
	 )            
	            
	 DECLARE @FINAL as TABLE            
	 (            
	  OrderId INT,             
	  AptCode VARCHAR(10),             
	  ImageURL VARCHAR(200)             
	 )            
	   
	 DECLARE @Tbl_RecommendedTripsSavings As Table  
	 (   
	 tripKey INT  
	 ,tripSavedKey UNIQUEIDENTIFIER  
	 ,TripComponentType INT  
	 ,currentPrice FLOAT  
	 ,originalPrice FLOAT  
	 ,originalTotalPrice FLOAT  
	 ,currentTotalPrice FLOAT  
	 ,OriginAirportCode VARCHAR(50)  
	 ,DestinationAirportCode VARCHAR(50)  
	 ,AdultCount INT  
	 ,ChildCount INT  
	 ,savings FLOAT  
	 )  
	   
	 -- DECLARE @Tbl_RecommendedTripsSavingsFinal As Table  
	 --(   
	 --tripKey INT  
	 --,tripSavedKey UNIQUEIDENTIFIER  
	 --,TripComponentType INT  
	 --,currentPrice FLOAT  
	 --,originalPrice FLOAT  
	 --,originalTotalPrice FLOAT  
	 --,currentTotalPrice FLOAT  
	 --,OriginAirportCode VARCHAR(50)  
	 --,DestinationAirportCode VARCHAR(50)  
	 --,AdultCount INT  
	 --,ChildCount INT  
	 --,savings FLOAT  
	 --)                   
--SELECT GETDATE() [1]
	  
	INSERT INTO @Tbl_RecommendedTripsSavings   
	SELECT   
	VWREC.tripKey  
	,VWREC.tripSavedKey  
	,VWREC.TripComponentType  
	,VWREC.currentPrice  
	,VWREC.originalPrice  
	,VWREC.originalTotalPrice  
	,VWREC.currentTotalPrice  
	,VWREC.OriginAirportCode  
	,VWREC.DestinationAirportCode  
	,VWREC.AdultCount  
	,VWREC.ChildCount  
	,VWREC.savings FROM vw_RecommendedTripsSavings VWREC  
	INNER JOIN Trip T ON VWREC.tripKey = T.tripKey  
	WHERE VWREC.savings <= -10 AND T.tripComponentType = VWREC.TripComponentType AND T.tripStatusKey <> 17   
--SELECT GETDATE() [2]
	  
	  
	   
	--INSERT INTO @Tbl_RecommendedTripsSavings   
	--EXEC USP_GetRecommendedDeals  
	  
	--INSERT INTO @Tbl_RecommendedTripsSavingsFinal  
	--SELECT RTS.tripKey  
	--,RTS.tripSavedKey  
	--,RTS.TripComponentType  
	--,RTS.currentPrice  
	--,RTS.originalPrice  
	--,RTS.originalTotalPrice  
	--,RTS.currentTotalPrice  
	--,RTS.OriginAirportCode  
	--,RTS.DestinationAirportCode  
	--,RTS.AdultCount  
	--,RTS.ChildCount  
	--,RTS.savings FROM @Tbl_RecommendedTripsSavings RTS INNER JOIN Trip T ON RTS.tripKey = T.tripKey  
	--WHERE RTS.TripComponentType = T.tripComponentType  
	  
	--SELECT * FROM @Tbl_RecommendedTripsSavingsFinal  
	--SELECT * FROM @Tbl_RecommendedTripsSavings  
	  
	 INSERT INTO #tripdetails ( tripKey  , tripsavedKey   ,triprequestkey   , tripstartdate   ,tripenddate   ,tripfrom  ,tripTo , tripComponentType ,tripComponents, rankRating, currentTotalPrice, UserName, FacebookUserUrl )                    
	  SELECT  t1.tripKey  , t1.tripsavedKey,t1.triprequestkey,startdate, enddate,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType     
		, CASE           
		  WHEN t1.tripComponentType = 1 THEN 'Air'          
		  WHEN t1.tripComponentType = 2 THEN 'Car'          
		  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
		  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
		  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
		  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
		  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
		 END AS tripComponents,                     
	  (CASE WHEN watchersCount = 1 THEN 2                     
	  WHEN  watchersCount between 2 and 4    THEN  5                     
	  WHEN watchersCount > 4 THEN 7 END ) as [Rank],  
	  recommended.currentTotalPrice as CurrentTotalPrice,  
	  UI.userFirstName + ' ' + UI.userLastName as UserName,
	  ISNULL(UM.ImageURL,'') as FacebookUserUrl  
	  FROM Trip T1          
	  INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey AND t1.tripComponentType = recommended.TripComponentType  
	  INNER JOIN Vault..[User] UI ON T1.userKey = UI.userKey                             
	  LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId
	  INNER JOIN                     
	  (SELECT MIN(tripKey) tripkey  , TS.tripSavedKey ,COUNT(tripKEY) as  watchersCount                      
	                  
	  FROM trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey where siteKey =@siteKey and T.tripStatusKey <> 17         
	     
	  Group by TS.tripSavedKey                      
	  )  AS DERIED on t1.tripKey =DERIED.tripkey                     
	  Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey           
	  where  T1.tripStatusKey <> 17  and  t1.startdate > DATEAdd(DAY,1 ,getdate())  and  (case when  @cityType = 'From' then   TR.tripFrom1                       
	  when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end) = isnull(@cityCode ,(case when  @cityType = 'From' then   TR.tripFrom1                     when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end))                   
	  AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
	  AND t1.tripKey <> @tripKey    
	  order by [RANK] desc ,tripkey desc                     

--SELECT GETDATE() [3]
	  
	       
	  declare @otherTrips as bit = 0                    
	  if   (SELECT COUNT(TripdetailsKey)  from #tripdetails) < 6 AND @cityCode IS NOT NULL                
	  BEGIN             
	   SET @otherTrips = 1                     
	 insert into #tripdetails ( tripKey  , tripsavedKey   ,triprequestkey   , tripstartdate   ,tripenddate   ,tripfrom  , tripTo , tripComponentType  , tripComponents ,rankRating, currentTotalPrice, UserName, FacebookUserUrl )                    
	   SELECT  t1.tripKey  , t1.tripsavedKey   ,t1.triprequestkey   ,  startdate   , enddate   ,tr.tripFrom1  , tr.tripTo1 , t1.tripComponentType      
		, CASE           
		  WHEN t1.tripComponentType = 1 THEN 'Air'          
		  WHEN t1.tripComponentType = 2 THEN 'Car'          
		  WHEN t1.tripComponentType = 3 THEN 'Air,Car'          
		  WHEN t1.tripComponentType = 4 THEN 'Hotel'          
		  WHEN t1.tripComponentType = 5 THEN 'Air,Hotel'          
		  WHEN t1.tripComponentType = 6 THEN 'Car,Hotel'          
		  WHEN t1.tripComponentType = 7 THEN 'Air,Car,Hotel'          
		 END AS tripComponents,                          
	   (case when watchersCount = 1 then 2                     
	   when watchersCount between 2 and 4   then  5                     
	   when watchersCount > 4 then 7 end ) as [Rank],  
	 recommended.currentTotalPrice as CurrentTotalPrice,  
	 UI.userFirstName + ' ' + UI.userLastName as UserName,
	 ISNULL(UM.ImageURL,'') as FacebookUserUrl                                              
	   FROM Trip T1      INNER JOIN @Tbl_RecommendedTripsSavings recommended On recommended.tripkey = T1.tripKey              
	   INNER JOIN                     
	   (select MIN(tripKey) tripkey  , TS.tripSavedKey ,COUNT(tripKEY) as  watchersCount                      
	                  
	   from trip T inner join TripSaved TS on T.tripSavedKey = TS.tripSavedKey where siteKey =@siteKey  and  T.tripStatusKey <> 17                     
	   Group by TS.tripSavedKey                      
	   )  AS DERIED on t1.tripKey =DERIED.tripkey                     
	   Inner join TripRequest TR on T1.tripRequestKey = Tr.tripRequestKey                     
	   INNER JOIN Vault..[User] UI on T1.userKey = UI.userKey               
	   LEFT JOIN Loyalty..UserMap UM ON UI.userKey = UM.UserId
	   where   T1.tripStatusKey <> 17    and     t1.startdate >DATEAdd(DAY,1 ,getdate()) and ( case when  @cityType = 'From' then   TR.tripFrom1                       
	   when @cityType = 'To' then Tr.tripTo1 else TR.tripFrom1    end )<>   @cityCode                   
	   AND (T1.tripComponentType &   (CASE WHEN @tripComponentType = 0 THEN T1.tripComponentType ELSE @tripComponentType END )) > 0                   
		AND t1.tripKey <> @tripKey    
	   order by [RANK] desc ,tripkey desc     
	    
--SELECT GETDATE() [4]
	  
	       
	  END      
	                   
	  IF ( @otherTrips = 1)                     
	  BEGIN                     
	   declare @lastCount as int = 9                     
	   IF ( SELECT COUNT(TripdetailsKey) from #tripdetails)  > 9                    
	   BEGIN                     
		SET @lastCount = 9                     
	   END                     
	  END                    
	  
	 --delete from #tripdetails where TripdetailsKey > @lastCount  
	        
	 UPDATE #tripdetails SET rankRating = 1 where           ( case when  @cityType = 'From' then    tripFrom                        
	   WHEN @cityType = 'To' then tripTo  else tripFrom     end )<>   @cityCode         
	                     
	 DECLARE @deal table                    
	 (                    
	  dealId int ,                     
	  tripkey int ,                    
	 componentType int                     
	 )     
	                
	 Insert @deal                     
	 SELECT MAX(TripSavedDealKey),TSD.tripKey ,componentType  FROM TripSavedDeals TSD inner join #tripdetails TD on tsd.tripKey =TD.tripKey                     
	 --where Convert(Date,TSD.creationDate )=  Convert(Date,getdate())                     
	 group by tsd.tripKey ,componentType   
	                   
--SELECT GETDATE() [5]
	  
	  
	  
	 update #tripdetails SET tripAirsavings =  
	   (ISNULL(DTAP.tripAdultBase,Dtap.tripSeniorBase) + ISNULL(DTAP.tripAdultTax,DTAP.tripSeniorTax))   
	   - (ISNULL(OTAP.tripAdultBase,otap.tripSeniorBase) + ISNULL(OTAP.tripAdultTax,otap.tripSeniorTax))  
	 FROM TripAirResponse OTR inner join TripAirPrices OTAP                      
	 ON OTR.searchAirPriceBreakupKey = OTAP.tripAirPriceKey                    
	 inner join #tripdetails T ON t.tripsavedKey = OTR.tripguidkey                     
	 inner join @deal  D on t.tripKey = d.tripkey                     
	 inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
	 inner join TripAirResponse DTR                     
	 ON DTR.airResponseKey = tsd.responseKey                     
	 inner join TripAirPrices DTAP                      
	 ON DTR.searchAirPriceBreakupKey = DTAP.tripAirPriceKey                    
	                     
--SELECT GETDATE() [6]	                     

	DECLARE @THR AS TABLE                     
	(                    
		tripGUIDKey uniqueidentifier NULL                     
		,hotelTotalPrice Float
		,responseKey uniqueidentifier
	)   

insert into @THR (tripGUIDKey,hotelTotalPrice, responseKey)
Select 
	tripGUIDKey
	,hotelTotalPrice
	--,hotelResponseKey
	--,d.dealId 
	--,tsd.TripSavedDealKey
	,tsd.responseKey
from TripHotelResponse thr
inner join #tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
inner join @deal  D on tD.tripKey = d.tripkey                     
inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
--SELECT GETDATE() [7]	



	DECLARE @DTR AS TABLE                     
	(                    
		 tripGUIDKey uniqueidentifier NULL                     
		--,DTR_hotelTotalPrice Float
		--,TSD_hotelTotalPrice Float
		,triphotelsavings float
	) 
Insert into @DTR (tripGUIDKey,triphotelsavings )
Select	tsd.tripGUIDKey
		--,DTR.hotelTotalPrice
		--,tsd.hotelTotalPrice
		,(DTR.hotelTotalPrice - tsd.hotelTotalPrice)
from @THR tsd
inner join TripHotelResponse DTR ON DTR.hotelResponseKey = tsd.responseKey 
--SELECT GETDATE() [8]

update  #tripdetails 
	 SET triphotelsavings = TD.triphotelsavings --(( DTR.hotelTotalPrice - THR.hotelTotalPrice )  ) 
	 FROM TripHotelResponse THR 
		inner join @DTR TD on thr.tripGUIDKey =td.tripGUIDKey    

			
		
/*
To Validate New Logic vs Old Logic

Select  THR.tripGUIDKey
		,triphotelsavings
		into #NewTB
	 FROM TripHotelResponse THR 
		inner join @DTR TD on thr.tripGUIDKey =td.tripGUIDKey    


Select thr.tripGUIDKey
	  ,triphotelsavings = (( DTR.hotelTotalPrice - THR.hotelTotalPrice )  ) 
	  into  #OldTB
	 FROM TripHotelResponse THR 
		inner join #tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
		inner join @deal  D on tD.tripKey = d.tripkey                     
		inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
		inner join TripHotelResponse DTR ON DTR.hotelResponseKey = tsd.responseKey 

--Select 	* from #NewTB
--Select * from #OldTB

			
--- Old Code Below 	                   
	 update  #tripdetails 
	 SET triphotelsavings = (( DTR.hotelTotalPrice - THR.hotelTotalPrice )  ) 
	 FROM TripHotelResponse THR 
		inner join #tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
		inner join @deal  D on tD.tripKey = d.tripkey                     
		inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId                     
		inner join TripHotelResponse DTR ON DTR.hotelResponseKey = tsd.responseKey  
*/		                   
--SELECT GETDATE() [9]
--DECLARE #CARTHR AS TABLE                     
CREATE TABLE #CARTHR
	(                    
		 tripGUIDKey uniqueidentifier NULL                     
		,responseKey uniqueidentifier		 
		,THR_SearchCarPrice  Float
		,THR_searchCarTax  Float
		,THR_CarTotalPrice Float
	)   

Insert into #CARTHR
Select   thr.tripGUIDKey
		,tsd.responseKey 
		,THR_SearchCarPrice = THR.SearchCarPrice
		,THR_searchCarTax = THR.searchCarTax
		,THR_CarTotalPrice = (THR.SearchCarPrice+ THR.searchCarTax)
FROM TripCarResponse THR 
	inner join #tripdetails TD on thr.tripGUIDKey =td.tripsavedKey                     
	inner join @deal  D on td.tripKey = d.tripkey                     
	inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId 	

--SELECT GETDATE() [10]	 
DECLARE @CARDTR AS TABLE                     
	(                    
		 carResponseKey uniqueidentifier NULL                     
		,DTR_SearchCarPrice  Float
		,DTR_searchCarTax  Float
		,DTR_CarTotalPrice Float
	)  

Insert Into @CARDTR
Select DTR.carResponseKey
	  ,DTR.SearchCarPrice 
	  ,DTR.searchCarTax
	  ,DTR.SearchCarPrice + DTR.searchCarTax
	FROM #CARTHR THR 
	inner join TripCarResponse DTR ON DTR.carResponseKey = THR.responseKey  	


--SELECT GETDATE() [11]		                 

update  #tripdetails SET tripcarsavings =   ( DTR.DTR_CarTotalPrice)   - ( THR.THR_CarTotalPrice)                     
	FROM #CARTHR THR 
	inner join @CARDTR DTR ON DTR.carResponseKey = THR.responseKey 
		
--SELECT GETDATE() [12]		                 

/* Old Logic 	                 
	update  #tripdetails SET tripcarsavings =   ( DTR.SearchCarPrice+ DTR.searchCarTax)   - ( THR.SearchCarPrice+ THR.searchCarTax)                     
	FROM TripCarResponse THR 
	inner join #tripdetails TD on thr.tripGUIDKey = td.tripsavedKey                     
	inner join @deal  D on td.tripKey = d.tripkey                     
	inner join TripSavedDeals TSD on tsd.TripSavedDealKey = d.dealId           
	inner join TripCarResponse DTR ON DTR.carResponseKey = tsd.responseKey   
*/	

	--DELETE FROM #tripdetails WHERE tripComponentType = 1 AND tripAirsavings IS NULL  
	--DELETE FROM #tripdetails WHERE tripComponentType = 2 AND tripcarsavings IS NULL  
	--DELETE FROM #tripdetails WHERE tripComponentType = 4 AND triphotelsavings IS NULL  
	--DELETE FROM #tripdetails WHERE tripComponentType = 3 AND (tripAirsavings IS NULL OR tripcarsavings IS NULL)  
	--DELETE FROM #tripdetails WHERE tripComponentType = 5 AND (tripAirsavings IS NULL OR triphotelsavings IS NULL)  
	--DELETE FROM #tripdetails WHERE tripComponentType = 6 AND (tripcarsavings IS NULL OR triphotelsavings IS NULL)  
	--DELETE FROM #tripdetails WHERE tripComponentType = 7 AND (tripAirsavings IS NULL OR triphotelsavings IS NULL OR tripcarsavings IS NULL)  

	 DELETE FROM #tripdetails WHERE (tripComponentType  & 1 ) > 0 AND tripAirsavings IS NULL  
	 DELETE FROM #tripdetails WHERE (tripComponentType  & 2 ) > 0 AND tripcarsavings IS NULL  
	 DELETE FROM #tripdetails WHERE (tripComponentType  & 4 ) > 0 AND triphotelsavings IS NULL  
	   
	delete from #tripdetails where TripdetailsKey > @lastCount  
	      
	DECLARE @IsAllowAds300by250 BIT      
	      
	SET @IsAllowAds300by250 = 1      
	      
	IF @page = 1 -- HOME PAGE       
	BEGIN       
	 -- GET ALLOW DISPLAY OF ADS 300by250 FROM HOME PAGE      
	 SELECT @IsAllowAds300by250 = AllowDisplayOf300By250Ads FROM CMS..CMS_HomePage      
	       
	END            
	ELSE IF @page = 10 -- CRUISE SECTION LANDING PAGE     
	BEGIN     
	 SELECT @IsAllowAds300by250 = AllowMerch FROM CMS..SectionLanding WHERE SectionLandingId = 2 -- 2=CRUISE            
	END    
	ELSE IF @page = 11 -- FLIGHTS SECTION LANDING PAGE     
	BEGIN     
	 SELECT @IsAllowAds300by250 = AllowMerch FROM CMS..SectionLanding WHERE SectionLandingId = 3 -- 3=FLIGHTS            
	END    
	ELSE IF @page = 12 -- CARS SECTION LANDING PAGE     
	BEGIN     
	 SELECT @IsAllowAds300by250 = AllowMerch FROM CMS..SectionLanding WHERE SectionLandingId = 4 -- 4=CARS            
	END      
	          
	IF @IsAllowAds300by250 = 1 -- IF IN ABOVE PAGES IT IS ALLOWED THEN DISPLAY IT      
	BEGIN      
	                  
	  IF @page = 0      
	  BEGIN       
	      
	   INSERT INTO @Offerdetails                    
	   SELECT TOP 3                    
		 M.MerchandiseId as OfferdetailsKey ,                    
		 NULL as tripKey ,                    
		 NULL as tripsavedKey ,                    
		 NULL as triprequestkey ,                    
		 NULL as tripstartdate ,                    
		 NULL as tripenddate ,                    
		 NULL as tripfrom ,                    
		 NULL as tripTo ,                    
		 NULL as tripComponentType ,    
		 NULL as tripComponents,                     
		 PriorityRank as rankRating,                    
		 NULL as tripAirsavings ,                      
		 NULL as tripcarsavings ,                    
		 NULL as triphotelsavings,                    
		 1 as isOffer,                    
		 OfferImage as OfferImageURL,    
		 ISNULL(LinktoPage, '') as LinktoPage,  
		 NULL as CurrentTotalPrice,  
		 '' as UserName,
		 '' as FacebookUserUrl  
	   FROM  CMS..Merchandise M                       
	   WHERE MerchandiseType = 'MerchandisingOffer300by250FormatDisplay'                    
	   and IsEnabled = 1                      
	   --and CitySpecificMatch = (select TOP 1 CityId from CMS..CMS_CityDetails where CityCode = ISNULL(@cityCode,CityCode))                      
	   and  (AptCodeSpecificMatch = ISNULL(@cityCode,AptCodeSpecificMatch) OR  AptCodeSpecificMatch = '')    
	   and GETDATE() between ISNULL(OfferDisplayStartDate,GETDATE()) and ISNULL(OfferDisplayEndDate,GETDATE())                      
	         
	   ORDER BY rankRating DESC                    
--SELECT GETDATE() [9]	        
	        
	  END       
	  ELSE      
	  BEGIN       
	                      
	   INSERT INTO @Offerdetails                    
	   SELECT TOP 3                    
		 M.MerchandiseId as OfferdetailsKey ,                    
		 NULL as tripKey ,                    
		 NULL as tripsavedKey ,                    
		 NULL as triprequestkey ,                    
		 NULL as tripstartdate ,                    
		 NULL as tripenddate ,                    
		 NULL as tripfrom ,                    
		 NULL as tripTo ,                    
		 NULL as tripComponentType ,      
		 NULL as tripComponents,                   
		 PriorityRank as rankRating,                    
		 NULL as tripAirsavings ,                      
		 NULL as tripcarsavings ,                    
		 NULL as triphotelsavings,                    
		 1 as isOffer,                    
		 OfferImage as OfferImageURL,    
		 ISNULL(LinktoPage, '') as LinktoPage,  
		 NULL as CurrentTotalPrice,  
		 '' as UserName,
		 '' as FacebookUserUrl                    
	   FROM  CMS..Merchandise M                       
	   INNER JOIN CMS..SitePlacement S ON M.MerchandiseId = S.CMSTableKey         
	   AND S.CMSTable = 'MerchandisingOffer300by250FormatDisplay'      
	   WHERE MerchandiseType = 'MerchandisingOffer300by250FormatDisplay'                    
	   and IsEnabled = 1                      
	   --and CitySpecificMatch = (select TOP 1 CityId from CMS..CMS_CityDetails where CityCode = ISNULL(@cityCode,CityCode))                      
	   and (AptCodeSpecificMatch = ISNULL(@cityCode,AptCodeSpecificMatch)  OR  AptCodeSpecificMatch = '')                    
	   --and HomePage = 1                            
	   and S.Page = @page      
	   and S.Visible = 1      
	   and GETDATE() between ISNULL(OfferDisplayStartDate,GETDATE()) and ISNULL(OfferDisplayEndDate,GETDATE())                      
	   ORDER BY rankRating DESC  
--SELECT GETDATE() [10]	                     
	  END                      
	      
	END      
	                     
	 SELECT  t.* , FA.CityName as FromCity, TA.CityName as ToCity ,    
	  CASE WHEN TA.CountryCode = 'US' THEN TA.StateCode  ELSE '' END AS ToState ,    
	  CASE WHEN TA.CountryCode = 'US' THEN '' ELSE CL.CountryName END AS ToCountry    
	      
	 FROM #tripdetails  T                    
	 left outer join                     
	 AirportLookup FA on                     
	 T.tripfrom = FA.AirportCode                     
	 left outer join                   
	 AirportLookup TA on                     
	 T.tripto = TA.AirportCode    
	 LEFT outer JOIN                   
	 vault..CountryLookUp CL ON     
	 TA.CountryCode = CL.CountryCode    
	 where TripdetailsKey between 1 and @resultCount                    
	                     
	 UNION                     
	                     
	 SELECT F.*, NULL as FromCity, NULL as  ToCity , NULL as ToState , NULL as ToCountry FROM @Offerdetails F                    
	                     
	 ORDER BY rankRating DESC   ,TripdetailsKey ASC         
	   
--SELECT GETDATE() [11] 
	                     
	 ---------------------------- DESTINATION IMAGES STARTS ----------------------------                  
	/*                  
	 SELECT DISTINCT TD.tripTo            
	 INTO #tmpTripTo                  
	 FROM #tripdetails TD                  
	*/            
	            
	            
	INSERT INTO @TripHotelGroup            
	SELECT  TR.tripToHotelGroupId, TR.tripTo1  , '' as URL            
	FROM TripRequest TR            
	INNER JOIN #tripdetails TD ON TR.tripRequestKey = TD.triprequestkey            
	             
--SELECT GETDATE() [12] 
	            
	            
	DECLARE @FromIndex INT,            
	  @ToIndex INT             
	            
	            
	SET @FromIndex = 1            
	SELECT @ToIndex = COUNT(*) FROM @TripHotelGroup            
	            
	WHILE(@FromIndex <= @ToIndex)            
	BEGIN            
	            
	 DECLARE @Url   VARCHAR(200),            
	   @HotelGroupId INT ,             
	   @AptCode  VARCHAR(5),            
	   @DestinationId INT            
	               
	             
	 SELECT             
	   @HotelGroupId = ISNULL(HotelGroupId,0),            
	   @AptCode = TripTo1             
	 FROM             
	   @TripHotelGroup            
	 WHERE             
	   Id = @FromIndex            
	             
	             
	 IF @HotelGroupId = 0 /* IF HOTEL GROUP ID IS NULL OR 0 THEN FETCH RECORDS STRAIGHT FROM DESTINATION TABLE .. */            
	 BEGIN             
	              
	  /* PICKING RANDOM IMAGE FROM DESTINATION PAGE */            
	            
	  SELECT @Url = ISNULL(ImageURL,'') FROM CMS..Destination D                 
	  INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                     
	  WHERE DI.IsEnabled = 1              
	  AND D.AptCode = @AptCode             
	  AND OrderId = @FromIndex            
	            
	  /* IF PICKING RANDOM IMAGE FROM DESTINATION PAGE FAILS THEN TAKE TOP 1 IMAGE ORDER BY ORDERID ASC FROM DESTINATION PAGE*/            
	  IF @Url IS NULL OR @Url = ''            
	  BEGIN             
	            
		SELECT TOP 1 @Url = ImageURL FROM CMS..Destination D                 
		INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId               
		WHERE DI.IsEnabled = 1              
		AND D.AptCode = @AptCode             
		ORDER BY OrderId ASC              
	               
	  END                 
	              
	              
	 END            
	 ELSE /* IF HOTEL GROUP ID IS NOT 0 OR NULL */            
	 BEGIN             
	              
	  SELECT @DestinationId =  ISNULL(DestinationId,0) FROM CMS..CustomHotelGroup            
	  WHERE HotelGroupId = @HotelGroupId             
	              
	  IF @DestinationId <> 0 /* IF DESTINATION ID IS PRESENT THEN TAKE STRAIGHT FROM DESTINATION TABLE FOR THT DESTINATION ID */            
	  BEGIN            
	   --            
	                
		SELECT TOP 1 @Url = ImageUrl FROM CMS..Destination D            
		INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                     
		WHERE DI.IsEnabled = 1              
		AND D.DestinationId = @DestinationId            
		ORDER BY OrderId ASC                     
	              
	  END            
	  ELSE /* IF DESTINATION ID IS 0 OR NULL THEN REPEAT THE SAME QUERY WHICH IS UED TO GET RECORDS WHEN HOTEL GROUP ID IS NULL OR 0. CHECK ABOVE QUERY ... */            
	  BEGIN             
	            
	                
		SELECT @Url = ISNULL(ImageURL,'') FROM CMS..Destination D                 
		INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                   
		WHERE DI.IsEnabled = 1              
		AND D.AptCode = @AptCode             
		AND OrderId = @FromIndex            
	            
		IF @Url IS NULL OR @Url = ''            
		BEGIN             
	            
		  SELECT TOP 1 @Url = ImageURL FROM CMS..Destination D                 
		  INNER JOIN CMS..DestinationImages DI ON D.DestinationId = DI.DestinationId                     
		  WHERE DI.IsEnabled = 1              
		  AND D.AptCode = @AptCode             
		  ORDER BY OrderId ASC              
	                 
		END                 
	            
	              
	  END             
	              
	              
	             
	 END             
	             
	 INSERT INTO @FINAL            
	 (            
	  OrderId ,             
	  AptCode ,             
	  ImageURL                
	 )             
	 VALUES            
	 (            
	  @FromIndex,            
	  @AptCode,            
	  @Url            
	 )            
	             
	 SET @Url = ''            
	 SET @AptCode  = ''            
	 SET @HotelGroupId = 0            
	 SET @DestinationId = 0             
	            
	 SET @FromIndex = @FromIndex + 1            
	            
	END             
	            
	               
	SELECT * FROM @FINAL            
	            
	            
	            
	/*            
	 SELECT OrderId, AptCode, ImageURL FROM CMS..Destination                  
	 INNER JOIN CMS..DestinationImages ON CMS..Destination.DestinationId = CMS..DestinationImages.DestinationId                  
	 INNER JOIN #tmpTripTo ON CMS..Destination.AptCode = #tmpTripTo.tripTo                  
	 ORDER BY AptCode, OrderId                  
	 */            
	                  
	 ---------------------------- DESTINATION IMAGES ENDS ----------------------------                    
	         
	                     
	  --DROP TABLE #tmpTripTo                  
        Drop table #TripDetails
        Drop table #CARTHR
END
GO
