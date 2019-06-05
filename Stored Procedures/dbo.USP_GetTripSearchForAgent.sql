SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetTripSearchForAgent]                  
(                  
 @TicketNumber VARCHAR(50),                  
 @RecordLocator VARCHAR(10),                  
 @PassengerLastName VARCHAR(400),                
 @PassengerFirstName VARCHAR(400),                  
 @airSegmentDepartureDate DATETIME,                  
 @Email VARCHAR(100),                  
 @MobileNumber VARCHAR(100),                  
 @siteKey int,             
 @origin VARCHAR(100),          
 @destination VARCHAR(100)          
)                  
AS                  
                  
BEGIN                  
                  
 SELECT T.TripKey,case when T.userKey=0 then 'Guest' else 'System' end as isGuest,recordLocator,TPI.PassengerFirstName,TPI.PassengerLastName,TPI.PassengerBirthDate,PassengerEmailID,T.CreatedDate,T.startDate, T.userKey,TR.tripFrom1,TR.tripTo1            
 ,T.tripStatusKey as 'Status' FROM Trip T             
  LEFT OUTER JOIN TRIPREQUEST TR ON T.tripRequestKey = TR.tripRequestKey AND TR.tripFrom1 = ISNULL(@origin, TR.tripFrom1) AND TR.tripTo1 = ISNULL(@destination, TR.tripTo1)            
  INNER JOIN TripPassengerInfo TPI ON T.tripKey = TPI.tripKey AND TPI.IsPrimaryPassenger = 1   
  --INNER JOIN (SELECT userKey,[userRoles] FROM [vault].[dbo].[UserProfile] where ([userRoles] & 1)> 0) AS  TPF ON T.userKey = TPF.userKey   
                   
 WHERE (@RecordLocator = '' OR T.recordLocator = @RecordLocator)                  
  AND (@PassengerLastName = '' OR TPI.PassengerLastName like @PassengerLastName+'%')                 
  AND (@PassengerFirstName = '' OR TPI.PassengerFirstName like @PassengerFirstName+'%')   
  AND (@Email = '' OR TPI.PassengerEmailID like @Email+'%')                  
  AND             
  (            
   @TicketNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TAL.TripKey                  
    FROM TripAirLegs TAL, TripAirLegPassengerInfo TLPI                  
    WHERE TAL.tripAirLegsKey = TLPI.tripAirLegKey AND TLPI.ticketNumber = @TicketNumber                  
   )                  
  )                  
  AND             
  (            
   @MobileNumber = '' OR T.TripKey IN                  
   (                  
    SELECT TP.TripKey                  
    FROM vault.dbo.[USER] U, vault.dbo.UserProfile UP, Trip TP                  
    WHERE U.UserKEy = TP.UserKey                   
    AND U.UserKey = UP.UserKey                  
    AND UP.cellPhone like @MobileNumber+'%'                  
   )                  
  )                  
  AND             
  (            
   @airSegmentDepartureDate = '1/1/1900' OR T.TripKey IN                  
   (                  
    SELECT t.tripkey                  
    FROM Trip t                   
    INNER JOIN                  
    (SELECT t.tripkey , MIN(S.airsegmentdeparturedate) AS DepartDate                  
    FROM Trip t INNER JOIN tripairresponse resp ON t.trippurchasedkey= resp.tripguidkey                   
    INNER JOIN tripairsegments  s  on resp.airresponsekey = s.airresponsekey                   
    GROUP BY t.tripkey,resp.airresponsekey) TSD                  
    ON t.tripKey = TSD.tripKEy                  
    WHERE CONVERT(VARCHAR(10),TSD.DepartDate ,101) = CONVERT(VARCHAR(10),@airSegmentDepartureDate,101)                  
   )                  
  )                  
  AND T.siteKey = @siteKey                  
  AND T.tripPurchasedKey is not null                  
 ORDER BY 1 DESC                  
                  
END
GO
