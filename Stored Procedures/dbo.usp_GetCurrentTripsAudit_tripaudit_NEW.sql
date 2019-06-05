SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 CREATE PROCEDURE [dbo].[usp_GetCurrentTripsAudit_tripaudit_NEW]              
 @PageName  NVARCHAR(500),                              
 @pageNo   INT,                          
 @pageSize  INT,                          
 @userkey  INT,                           
 @tripKey  INT = NULL,                              
 @fromDate  NVARCHAR(50),                              
 @toDate   NVARCHAR(50),                              
 @traveler  INT,                          
 @status   INT,                          
 @companyKey  INT = NULL ,                          
 @TripCompType VARCHAR(10),                           
 @siteKey  INT = NULL,                          
 @createdDate DATETIME = '01-01-1900 00:00:00',                          
 @totalRecords INT OUTPUT,                
 @sortField as varchar (200) ,                     
 @sortDirection as varchar(20)                                 
AS                              
BEGIN       
      
 IF OBJECT_ID('tempdb..#tblAirAudits') IS NOT NULL      
drop table #tblAirAudits      
      
 CREATE TABLE #tblAirAudits      
 (      
 PNR NVARCHAR(100),      
 lineType NVARCHAR(100),      
 AirAmount decimal(18,2)      
       
 )          
       
 IF OBJECT_ID('tempdb..#tblHotelAudits') IS NOT NULL      
drop table #tblHotelAudits      
      
 CREATE TABLE #tblHotelAudits      
 (      
 PNR NVARCHAR(100),       
 HotelAmount decimal(18,2)      
       
 )                                             
      
IF OBJECT_ID('tempdb..#tblUser') IS NOT NULL      
drop table #tblUser      
                           
 CREATE TABLE #tblUser                              
 (                              
  UserKey INT                              
 )          
      
IF OBJECT_ID('tempdb..#tmpTrip') IS NOT NULL      
drop table #tmpTrip      
                           
 CREATE TABLE #tmpTrip                              
 (                              
  RowID   INT,                              
  tripKey   INT,                              
  TripRequestKey INT,                              
  tripName  NVARCHAR(100),                              
  userKey   INT,                              
  recordLocator NVARCHAR(100),                              
  startDate  DATETIME,                              
  endDate   DATETIME,                              
  tripStatusKey INT,                              
  agencyKey  INT,                              
  userFirstName NVARCHAR(300),                              
  userLastName NVARCHAR(300),                              
  userLogin  NVARCHAR(300),        
  tripPurchasedKey uniqueidentifier,      
  airSavingAmount decimal(18,2),      
  hotelSavingAmount decimal(18,2)              
 )                  
                               
 IF(@traveler IS NOT NULL AND @traveler <> '' )                               
 BEGIN                              
  INSERT INTO #tblUser                              
   SELECT @traveler                              
 END                              
 ELSE                              
 BEGIN                              
  INSERT INTO #tblUser                              
  SELECT DISTINCT userKey FROM Vault.dbo.GetAllArrangees(@userkey, @companyKey)                           
 END        
          
 IF @PageName <> N'bids'                          
 BEGIN                          
  SET @tripKey = CASE WHEN @tripKey IS NULL THEN 0 ELSE @tripKey END                           
 END                          
                           
 --DECLARE @strQuery NVARCHAR(MAX), @paramDesc NVARCHAR(200)         
  BEGIN      
 INSERT INTO #tblAirAudits      
 Select pnr,line_type,amount from  AI.dbo.ff_work fw where ff_work_timestamp in (select max(ff_work_timestamp) from AI.dbo.ff_work fw group by pnr,line_type)    
 and fw.line_type='same'       
  END       
        
   BEGIN      
 INSERT INTO #tblHotelAudits      
 Select tr.pnr,sum(fw.rate) from  AI.dbo.hotelfinder fw      
 Left outer JOIN ai.dbo.trip tr ON fw.trip_id=tr.trip_id       
 where fw.creation_date in (select Max(creation_date) from AI.dbo.hotelfinder group by trip_id,property_id)      
 group by tr.pnr       
   END       
                           
  BEGIN      
  INSERT INTO #tmpTrip(tripKey, TripRequestKey, tripName, userKey, recordLocator, startDate, endDate, tripStatusKey, agencyKey,      
  userFirstName, userLastName, userLogin, tripPurchasedKey, airSavingAmount, hotelSavingAmount)     
      
  SELECT Trip.tripKey, Trip.TripRequestKey, Trip.tripName, Trip.userKey, isnull(Trip.recordLocator,Trip.passiveRecordLocator), Trip.startDate,              
   Trip.endDate, Trip.tripStatusKey, Trip.agencyKey,                             
   U.userFirstName, U.userLastName, U.userLogin   ,isnull(trip.tripPurchasedKey,Trip.tripSavedKey),tad.AirAmount,thd.HotelAmount 
      
  FROM trip WITH(NOLOCK)        
   INNER JOIN Vault.dbo.[User] U WITH(NOLOCK) ON trip.userKey =  U.UserKey AND Trip.tripStatusKey <> 10                 
   INNER JOIN TripStatusLookup S WITH (NOLOCK) ON Trip.tripStatusKey = S.tripStatusKey               
   INNER JOIN #tblUser TU ON U.userKey = TU.userKey              
   INNER JOIN TripAirResponse TAR WITH (NOLOCK) ON Isnull(trip.tripPurchasedKey,trip.tripSavedKey) = TAR.tripGUIDKey     
    
   LEFT OUTER JOIN #tblAirAudits tad ON tad.PNR  =(case when trip.trippurchasedkey is not null then trip.recordlocator else trip.passiveRecordLocator end)     
   LEFT OUTER JOIN #tblHotelAudits thd ON thd.PNR  = (case when trip.trippurchasedkey is not null then trip.recordlocator else trip.passiveRecordLocator end)     
   LEFT OUTER JOIN TripCarResponse TCR WITH (NOLOCK) ON TCR.tripguidkey = (case when trip.trippurchasedkey is not null then trip.trippurchasedkey else trip.tripsavedkey end )             
   LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON  THR.tripGUIDKey =(case when trip.trippurchasedkey is not null then trip.trippurchasedkey else trip.tripsavedkey end )              
   --LEFT OUTER JOIN TripCarResponse TCR1 WITH (NOLOCK) ON trip.tripSavedKey = TCR1.tripGUIDKey              
   --LEFT OUTER JOIN TripHotelResponse THR1 WITH (NOLOCK) ON trip.tripSavedKey = THR1.tripGUIDKey            
   --LEFT OUTER JOIN TripAirSegmentOptionalServices OPT WITH (NOLOCK) ON trip.tripKey = OPT.tripKey AND OPT.isDeleted = 0                 
   WHERE 1=1                           
    AND Trip.tripKey = CASE WHEN @tripKey = 0 THEN Trip.tripKey ELSE @tripKey END                           
    AND Trip.startDate between @fromDate and @toDate                           
    --AND dbo.IsTripStatusAsPerType(ISNULL(@status,Trip.tripStatusKey),@PageName) = 1                           
    --AND Trip.recordlocator IS NOT NULL AND Trip.recordlocator <> ''    
     AND Trip.endDate >= GETDATE() AND Trip.tripStatusKey = ISNULL(@status,Trip.tripStatusKey)              
    AND Trip.siteKey = CASE WHEN @siteKey IS NULL THEN Trip.siteKey ELSE @siteKey END              
      
          
  --SELECT @totalRecords = COUNT(*) FROM #tmpTrip     ---get total records count in output parameter                
        
   -- select * from #tmpTrip                      
  SELECT distinct trip.tripKey, TripRequestKey, tripName, userKey, recordLocator, startDate, endDate,                          
   tripStatusKey, agencyKey, userFirstName, userLastName, userLogin, airSavingAmount,hotelSavingAmount                        
  FROM #tmpTrip trip                
  --WHERE RowID > (@pageNo-1)*@pageSize AND RowID <= @pageNo*@pageSize                  
                            
        ---  get the Air, car and hotel response detail for filtered trips                              
  SELECT vt.TYPE, vt.tripKey, vt.recordLocator, vt.basecost, vt.tax, vt.vendorcode,                          
   vt.VendorName, vt.airSegmentDepartureAirport, vt.airSegmentArrivalAirport, vt.flightNumber,                     
   vt.departuredate, vt.arrivaldate, vt.carType, vt.Ratingtype, vt.responseKey, vt.vendorLocator              
  FROM vw_TripDetails_tripaudit_Audit vt WITH(NOLOCK)                           
   INNER JOIN #tmpTrip tmp ON tmp.tripKey = vt.tripKey              
   INNER JOIN TripStatusLookup S WITH (NOLOCK) ON tmp.tripStatusKey = S.tripStatusKey              
   INNER JOIN TripAirResponse TAR WITH (NOLOCK) ON tmp.tripPurchasedKey = TAR.tripGUIDKey              
   LEFT OUTER JOIN TripCarResponse TCR WITH (NOLOCK) ON tmp.tripPurchasedKey = TCR.tripGUIDKey              
   LEFT OUTER JOIN TripHotelResponse THR WITH (NOLOCK) ON tmp.tripPurchasedKey = THR.tripGUIDKey              
   LEFT OUTER JOIN TripAirSegmentOptionalServices OPT WITH (NOLOCK) ON tmp.tripKey = OPT.tripKey AND OPT.isDeleted = 0                 
         
                                  
  SELECT OPT.*                       
  FROM TripAirSegmentOptionalServices OPT WITH(NOLOCK)                           
   INNER JOIN #tmpTrip T ON OPT.tripKey = T.tripKey AND isDeleted = 0               
 END           
 END
GO
