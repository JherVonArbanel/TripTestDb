SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		R. Kantor
-- Create date: 12/20/1026
-- Description:	Purge Gender and DOB after 90 days 
--              from completion of travel
-- =============================================
CREATE PROCEDURE [dbo].[USP_PurgeTSAInfo]
	-- Add the parameters for the stored procedure here
	@age int = 90,
	@sitekey int = 20
-- age integer value = 90 default
-- sitekey integer value spiritirop = 20 default
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


    -- Insert statements for procedure here
SELECT a.[tripKey]
      ,[tripName]
      ,[userKey]
      ,[recordLocator]
      ,[startDate]
      ,[endDate]
      ,[tripStatusKey]
      ,[tripSavedKey]
      ,[tripPurchasedKey]
      ,[agencyKey]
      ,[tripComponentType]
      ,a.[tripRequestKey]
      ,[CreatedDate]
      ,[meetingCodeKey]
      ,[deniedReason]
      ,[siteKey]
      ,[isBid]
      ,[PurchaseComponentType]
      ,[tripTotalBaseCost]
      ,[tripTotalTaxCost]
      ,[ModifiedDateTime]
      ,[IsWatching]
      ,[tripOriginalTotalBaseCost]
      ,[tripOriginalTotalTaxCost]
      ,[tripInfantWithSeatCount]
      ,[passiveRecordLocator]
      ,[isAudit]
      ,[bookingCharges]
      ,[isUserCreatedSavedTrip]
      ,[ISSUEDATE]
      ,[privacyType]
      ,[HomeAirport]
      ,[DestinationSmallImageURL]
      ,[FollowersCount]
      ,[tripCreationPath]
      ,[CrowdCount]
      ,[TrackingLogID]
      ,[bookingFeeARC]
      ,[IsHotelCrowdSavings]
      ,[SabreCreationDate]
      ,[promoId]
      ,[cashRewardId]
      ,[HostUserId]
      ,[RetainOrReplace]
      ,[GroupKey]
      ,b.[PassengerEmailID]
      ,b.[PassengerFirstName]
      ,b.[PassengerLastName]
      ,b.[PassengerBirthDate]
      ,b.[PassengerGender]
      FROM [Trip].[dbo].[Trip]a, [trip].[dbo].[TripPassengerInfo]b
      where datediff(day,endDate,CURRENT_TIMESTAMP) > @age and sitekey = @sitekey and a.tripKey = b.TripKey
	   
	
END
GO
