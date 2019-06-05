SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Author,,Rohita Patel>  
-- Create date: <Create Date,,27-05-13>  
-- Description: <Description,,>  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_TripSyncup_INSERT] 
 
 @userId  int
 
AS
BEGIN  

 SET NOCOUNT ON;  
 
	INSERT INTO [Trip].[dbo].[TripSyncup] ([SiteKey],[UserId],[TripId],[TripName],[RefrenceId],[Status],[Remarks],[CreatedDate],[Origin],[Destination],
	[StartDate],[EndDate],[TripCreatedDate],[TripStatus]) 
	SELECT TR.siteKey,userId=@userId,TR.tripKey,tripName=AL_To.CityName++' Trip',refrenceId=NEWID(),sStatus=1,remarks=null,createdDate=getdate(),
	origin = AL_From.CityName + ', '  + AL_From.AirportCode +', '+AL_From.CountryCode,destination = AL_To.CityName + ', '  + AL_To.AirportCode +', '+AL_To.CountryCode  
	,tripFromDate1,tripToDate1,TR.CreatedDate,TR.tripStatusKey  
	FROM [Trip].[dbo].[Trip] TR
		INNER JOIN [Trip].[dbo].[TripRequest] TReq ON TR.tripRequestKey=TReq.tripRequestKey
		INNER JOIN [Trip].[dbo].[airportlookup] AL_From on  AL_From.AirportCode=TReq.tripFrom1
		INNER JOIN [Trip].[dbo].[airportlookup] AL_To on  AL_To.AirportCode=TReq.tripTo1
	WHERE  tripStatusKey <> 17 AND tripKey Not In (SELECT tripId FROM TripSyncup WHERE userId=@userId) AND TR.userKey=@userId
 
END
GO
