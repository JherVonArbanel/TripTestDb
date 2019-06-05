SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 16th May 2014
-- Description:	Map old savetrip with crowd id
-- =============================================
--EXEC USP_MapCrowdIdWithOldSaveTrip

CREATE PROCEDURE [dbo].[USP_MapCrowdIdWithOldSaveTrip]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--DECLARATION
	DECLARE @countToExecute INT = 0
			,@incrementCount INT = 1
			,@parentId INT
			,@SavetripId UNIQUEIDENTIFIER
			,@parentSavetripId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
			,@TripRequestKey INT
			,@childTripRequestKey INT
			,@DestinationCity VARCHAR(3)
			,@childDestinationCity VARCHAR(3)
			,@CrowdId INT
			,@parentCrowdId INT
			,@recursiveIncrementCount INT = 1
			,@recursiveCountToExecute INT = 1
			,@recursiveParentSaveTripId UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
			
			
	DECLARE @ParentSaveTrip AS TABLE
	(
		ParentId INT IDENTITY(1,1)
		,SaveTripId UNIQUEIDENTIFIER
		,isUpdated BIT DEFAULT(0)
	)
	
	DECLARE @FollowSaveTrip AS TABLE
	(
		ParentId INT IDENTITY(1,1)
		,SaveTripId UNIQUEIDENTIFIER
		,ParentSaveTripId UNIQUEIDENTIFIER
		,isUpdated BIT DEFAULT(0)
	)
		
	INSERT INTO @ParentSaveTrip 
	(
		SaveTripId
	)
	SELECT tripSavedKey FROM TripSaved 
	WHERE parentSaveTripKey IS NULL
		
	Set @countToExecute = (Select COUNT(SaveTripId) from @ParentSaveTrip)  
    
    --LOOP FOR PARENT SAVETRIP
	WHILE (@incrementCount <= @countToExecute)  
	BEGIN
		SELECT TOP 1 @parentId = ParentId
		,@SavetripId = SaveTripId
		FROM @ParentSaveTrip
		WHERE isUpdated = 0
		
		SELECT @TripRequestKey = tripRequestKey 
		FROM Trip 
		WHERE tripSavedKey = @SavetripId
		
		SELECT @DestinationCity = tripTo1 
		FROM TripRequest
		WHERE tripRequestKey = @TripRequestKey
		
		INSERT INTO Crowd
		(
			crowdDestination
		)
		VALUES
		(
			@DestinationCity
		)
		SELECT @CrowdId = SCOPE_IDENTITY()
		
		UPDATE TripSaved
		SET CrowdId = @CrowdId
		WHERE tripSavedKey = @SavetripId
		
		UPDATE @ParentSaveTrip
		SET isUpdated = 1
		WHERE ParentId = @parentId
		
		SET  @incrementCount += 1
	END
	--END LOOP FOR PARENT SAVETRIP
	
	--INSERT CHILD SAVE TRIP
	INSERT INTO @FollowSaveTrip
	(
		SaveTripId
		,ParentSaveTripId
	)
	SELECT tripSavedKey
	,parentSaveTripKey  
	FROM TripSaved 
	WHERE parentSaveTripKey IS NOT NULL
	
	SET @incrementCount = 1
	SET @countToExecute = (SELECT COUNT(SaveTripId) FROM @FollowSaveTrip)
	
	--LOOP FOR CHILD SAVETRIP	
	WHILE (@incrementCount <= @countToExecute)  
	BEGIN
		
		SELECT TOP 1 @parentId = ParentId 
		,@SavetripId = SaveTripId
		,@parentSavetripId = ParentSaveTripId 
		FROM @FollowSaveTrip
		WHERE isUpdated = 0
		
		SET @recursiveIncrementCount = 1
		SET @recursiveCountToExecute = 1
		
		--RECURSIVE LOOP FOR SAVETRIP
		WHILE (@recursiveIncrementCount <= @recursiveCountToExecute)
		BEGIN
			
			SELECT @recursiveParentSaveTripId = ISNULL(parentSaveTripKey, '00000000-0000-0000-0000-000000000000')
			FROM TripSaved
			WHERE tripSavedKey = @parentSavetripId
			
			--WHEN THE FOLLOWED SAVETRIP ID IS NOT THE ACTUAL PARENT
			IF(@recursiveParentSaveTripId <> '00000000-0000-0000-0000-000000000000')
			BEGIN				
				SET @parentSavetripId = @recursiveParentSaveTripId
				SET @recursiveCountToExecute += 1
			END
			--THE ACTUAL PARENT
			ELSE
			BEGIN
				
				SELECT TOP 1 @TripRequestKey = tripRequestKey 
				FROM Trip 
				WHERE tripSavedKey = @parentSavetripId
				
				SELECT @DestinationCity = tripTo1 
				FROM TripRequest
				WHERE tripRequestKey = @TripRequestKey
				
				SELECT TOP 1 @childTripRequestKey = tripRequestKey 
				FROM Trip 
				WHERE tripSavedKey = @SavetripId					
				
				SELECT @childDestinationCity = tripTo1 
				FROM TripRequest
				WHERE tripRequestKey = @childTripRequestKey
				
				IF(ISNULL(@DestinationCity, '') <> ISNULL(@childDestinationCity, ''))
				BEGIN
					INSERT INTO Crowd
					(
						crowdDestination
					)
					VALUES
					(
						@childDestinationCity
					)
					SELECT @CrowdId = SCOPE_IDENTITY()
					
					UPDATE TripSaved
					SET CrowdId = @CrowdId
					WHERE tripSavedKey = @SavetripId
				END
				ELSE
				BEGIN
					SET @parentCrowdId = (SELECT CrowdId FROM TripSaved WHERE tripSavedKey = @parentSavetripId)
										
					--print 'parentCrowdId: ' + convert(varchar,@parentCrowdId)
					UPDATE TripSaved
					SET CrowdId = @parentCrowdId
					WHERE tripSavedKey = @SavetripId
				END								
				
			END			
			
			SET @recursiveIncrementCount += 1	
		END
		--END RECURSIVE LOOP FOR SAVETRIP
		
		UPDATE @FollowSaveTrip
		SET isUpdated = 1
		WHERE ParentId = @parentId	
		
		SET @incrementCount += 1 		
	END
	--END LOOP FOR CHILD SAVETRIP	
    
END
GO
