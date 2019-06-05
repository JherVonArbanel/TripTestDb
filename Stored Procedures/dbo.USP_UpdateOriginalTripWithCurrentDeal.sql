SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 05-05-2016
-- Description:	Updating Original Trip with today's deal.
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateOriginalTripWithCurrentDeal]
	-- Add the parameters for the stored procedure here
	@tripId bigint,
	@userId bigint 
	
AS
BEGIN

    DECLARE @airResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'
    DECLARE @hotelResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'
    DECLARE @carResponseKey uniqueidentifier = '00000000-0000-0000-0000-000000000000'
    DECLARE @saveTripKey uniqueidentifier
    DECLARE @originalSaveTripKey uniqueidentifier
    
    SELECT @saveTripKey = NEWID() --created new save tripkey
    
    --GET--all--responsekey--for--individual--component
    --AIR
    SELECT TOP 1 @airResponseKey = responseKey FROM Trip..TripSavedDeals WHERE tripKey=@tripId and componentType=1 ORDER BY creationDate DESC
    
    --CAR
    SELECT TOP 1 @carResponseKey = responseKey FROM Trip..TripSavedDeals WHERE tripKey=@tripId and componentType=2 ORDER BY creationDate DESC
    
    --HOTEL
    SELECT TOP 1 @hotelResponseKey = responseKey FROM Trip..TripSavedDeals WHERE tripKey=@tripId and componentType=4 ORDER BY creationDate DESC
    
    --Get original save tripkey
    SELECT @originalSaveTripKey = tripSavedKey FROM Trip..Trip WHERE tripKey=@tripId
    
    --Air--Update--Deal--Response--with--savetrip--key
    
    IF @airResponseKey <> '00000000-0000-0000-0000-000000000000'
    BEGIN
		UPDATE Trip..TripAirResponse SET tripGUIDKey =@saveTripKey WHERE airResponseKey = @airResponseKey
    END
    
    IF @carResponseKey <> '00000000-0000-0000-0000-000000000000'
    BEGIN
		UPDATE Trip..TripCarResponse SET tripGUIDKey =@saveTripKey WHERE carResponseKey = @carResponseKey
    END
    
    IF @hotelResponseKey <> '00000000-0000-0000-0000-000000000000'
    BEGIN
		UPDATE Trip..TripHotelResponse SET tripGUIDKey =@saveTripKey WHERE hotelResponseKey = @hotelResponseKey
    END

    INSERT INTO Trip..TripSaved (tripSavedKey,userKey,parentSaveTripKey,SplitFollowersCount,CrowdId,privacyType,createdDate)
	SELECT  @saveTripKey, @userId, NULL,SplitFollowersCount,CrowdId, privacyType, GETDATE() FROM Trip..TripSaved WHERE tripSavedKey = @originalSaveTripKey   
	
	UPDATE Trip..Trip SET tripSavedKey = @saveTripKey, RetainOrReplace = GETDATE() WHERE tripSavedKey = @originalSaveTripKey
	
	UPDATE Trip..TripSaved SET parentSaveTripKey = @saveTripKey WHERE parentSaveTripKey = @originalSaveTripKey
	
	--DELETE FROM Trip..TripSaved WHERE tripSavedKey = @originalSaveTripKey

END

GO
