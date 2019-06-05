SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_ADT_Get_Tripsdetail_Traveler]
(          
 @UserKey int,          
 @EmailAddress VARCHAR(110),          
 @LastName VARCHAR(100)        
  )   
As Begin  
  
if @UserKey = 0  
BEGIN  
 select T.tripKey, T.recordLocator,T.startDate,T.endDate,TP.PassengerFirstName,TP.PassengerLastName,TP.PassengerEmailID, T.tripStatusKey,   
 T.userKey,T.tripKey  from trip T  
 inner join TripPassengerInfo TP ON T.tripKey = TP.TripKey where T.userKey = @UserKey and TP.IsPrimaryPassenger=1  
 and TP.PassengerEmailID = @EmailAddress and TP.PassengerLastName = @LastName  and T.tripStatusKey <> 17 
End  
ELSE  
 select T.recordLocator,T.startDate,T.endDate,TP.PassengerFirstName,TP.PassengerLastName,TP.PassengerEmailID, T.tripStatusKey,   
 T.userKey,T.tripKey  from trip T  
 inner join TripPassengerInfo TP ON T.tripKey = TP.TripKey where T.userKey = @UserKey  and TP.IsPrimaryPassenger=1   and T.tripStatusKey <> 17 
END
GO
