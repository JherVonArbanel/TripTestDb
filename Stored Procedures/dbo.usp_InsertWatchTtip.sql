SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_InsertWatchTtip] 
(
@tripSavedKey uniqueidentifier ,
@noOfAdult int = 0, 
@noOfSenior int = 0,
@noOfChild int=0 ,
@noOfInfant int =0 ,
@noOfYouth int =0 ,
@noOfTotalTravler int = 0 ,
@noOFRooms int = 0 ,
@noOFcars int = 0 ,
@userKey bigint
)
AS
BEGIN 
INSERT INTO  Trip 
           (tripName,userKey ,startDate,endDate,tripStatusKey,tripSavedKey,agencyKey,tripComponentType ,tripRequestKey
           ,CreatedDate,siteKey ,isBid,isOnlineBooking,tripAdultsCount,tripSeniorsCount,tripChildCount,tripInfantCount,tripYouthCount
           ,noOfTotalTraveler,noOfRooms,noOfCars,recordLocator,IsWatching )
     
     
     (SELECT TOP 1 
            tripName  ,@userKey ,startDate ,endDate ,14,TS.tripSavedKey  ,agencyKey  ,tripComponentType ,tripRequestKey 
           ,GETDATE() ,siteKey ,isBid  ,isOnlineBooking,@noOfAdult,@noOfSenior,@noOfChild ,@noOfInfant,@noOfYouth ,
           @noOfTotalTravler ,@noOFRooms ,@noOFcars ,'',1 FROM 
        TripSaved TS inner join Trip t on TS.tripSavedKey = T.tripSavedKey and t.userKey =Ts.userKey 
        where ts.tripSavedKey =@tripSavedKey   and T.tripStatusKey <> 17 
        )
        SELECT SCOPE_IDENTITY()
END
GO
