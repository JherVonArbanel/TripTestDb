SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <17th Aug 17>
-- Description:	<To Insert Activity Travelcomponent>
-- =============================================
CREATE PROCEDURE [dbo].[SavePurchaseTrip_TravelComponent_Activity_Insert]
	-- Add the parameters for the stored procedure here
	@xmldata XML, @TripPurchaseKey uniqueidentifier, @tripId int, @TripPassenger SavePurchaseTrip_TripPassenger Readonly
AS
BEGIN
	DECLARE @activityResponseKey uniqueidentifier = NEWID()
	
	INSERT INTO TripActivityResponse( ActivityResponseKey, TripKey, TripGUIDKey, TripPassengerInfoKey, ConfirmationNumber, RecordLocator, TotalPrice, 
										ActivityType, ActivityTitle, ActivityText, ActivityDate, VoucherURL, CancellationFormURL, NoOfAdult,  
										NoOfChild, NoOfYouth, NoOfInfant, NoOfSenior, Link, ActivityCode, OptionCode, AdultPrice, ChildPrice,  
										SeniorPrice, InfantPrice, YouthPrice, RecommendedAdultPrice, RecommendedChildPrice, RecommendedSeniorPrice,  
										RecommendedInfantPrice, RecommendedYouthPrice, TotalNetRate)
	SELECT @activityResponseKey, @tripId, @TripPurchaseKey, P.TripPassengerInfoKey,
	  TripActivityResponse.value('(confirmationNumber/text())[1]','VARCHAR(50)') AS confirmationNumber,
	  TripActivityResponse.value('(RecordLocator/text())[1]','VARCHAR(50)') AS RecordLocator,
	  TripActivityResponse.value('(TotalPrice/text())[1]','float') AS TotalPrice,
	  TripActivityResponse.value('(ActivityType/text())[1]','VARCHAR(200)') AS ActivityType,
	  TripActivityResponse.value('(ActivityTitle/text())[1]','VARCHAR(500)') AS ActivityTitle,
	  TripActivityResponse.value('(ActivityText/text())[1]','VARCHAR(5000)') AS ActivityText,
	  (case when (charindex('-', TripActivityResponse.value('(ActivityDate/text())[1]','VARCHAR(30)')) > 0) 
			then CONVERT(datetime, TripActivityResponse.value('(ActivityDate/text())[1]','VARCHAR(30)'), 103) 
			else TripActivityResponse.value('(ActivityDate/text())[1]','datetime') end) AS ActivityDate,	  
	  TripActivityResponse.value('(VoucherURL/text())[1]','VARCHAR(500)') AS VoucherURL,
	  TripActivityResponse.value('(CancellationFormURL/text())[1]','VARCHAR(500)') AS CancellationFormURL,
	  TripActivityResponse.value('(NoOfAdult/text())[1]','int') AS NoOfAdult,
	  TripActivityResponse.value('(NoOfChild/text())[1]','int') AS NoOfChild,
	  TripActivityResponse.value('(NoOfYouth/text())[1]','int') AS NoOfYouth,
	  TripActivityResponse.value('(NoOfInfant/text())[1]','int') AS NoOfInfant,
	  TripActivityResponse.value('(NoOfSenior/text())[1]','int') AS NoOfSenior,	  
	  TripActivityResponse.value('(Link/text())[1]','VARCHAR') AS Link,
	  TripActivityResponse.value('(ActivityCode/text())[1]','VARCHAR(500)') AS ActivityCode,	  
	  TripActivityResponse.value('(OptionCode/text())[1]','VARCHAR(500)') AS OptionCode,
	  TripActivityResponse.value('(AdultPrice/text())[1]','float') AS AdultPrice,
	  TripActivityResponse.value('(ChildPrice/text())[1]','float') AS ChildPrice,
	  TripActivityResponse.value('(SeniorPrice/text())[1]','float') AS SeniorPrice,
	  TripActivityResponse.value('(InfantPrice/text())[1]','float') AS InfantPrice,
	  TripActivityResponse.value('(YouthPrice/text())[1]','float') AS YouthPrice,
	  TripActivityResponse.value('(RecommendedAdultPrice/text())[1]','float') AS RecommendedAdultPrice,
	  TripActivityResponse.value('(RecommendedChildPrice/text())[1]','float') AS RecommendedChildPrice,
	  TripActivityResponse.value('(RecommendedSeniorPrice/text())[1]','float') AS RecommendedSeniorPrice,
	  TripActivityResponse.value('(RecommendedInfantPrice/text())[1]','float') AS RecommendedInfantPrice,
	  TripActivityResponse.value('(RecommendedYouthPrice/text())[1]','float') AS RecommendedYouthPrice,
	  TripActivityResponse.value('(TotalNetRate/text())[1]','float') AS TotalNetRate
	FROM @xmldata.nodes('/Activity/TripActivityResponse')AS TEMPTABLE(TripActivityResponse)
		left outer join (select top 1 * from @TripPassenger) P on TripActivityResponse.value('(TripPassengerInfoKey/text())[1]','int') = P.PassengerKey
					
END
GO
