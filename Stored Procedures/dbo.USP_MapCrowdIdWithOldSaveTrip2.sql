SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 16th May 2014
-- Description:	Map old savetrip with crowd id
-- =============================================
--EXEC USP_MapCrowdIdWithOldSaveTrip3

CREATE PROCEDURE [dbo].[USP_MapCrowdIdWithOldSaveTrip2]
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
			,@SaveTripMappingId INT
			,@isSameDestination BIT
			,@tripDetailsId INT
						
	DECLARE @ParentSaveTrip AS TABLE
	(
		ParentId INT IDENTITY(1,1)
		,SaveTripId UNIQUEIDENTIFIER
		,isUpdated BIT DEFAULT(0)
	)
	
	DECLARE @TripDetails AS TABLE
	(
		TripDetailsId INT IDENTITY (1,1)
		,TripSavedKey UNIQUEIDENTIFIER
		,IsUpdated BIT DEFAULT(0)
	)
	
	CREATE TABLE #SaveTripMapping
	(
		SaveTripMappingId INT IDENTITY (1,1)
		,ChildSaveTripId UNIQUEIDENTIFIER
		,ParentSaveTripId UNIQUEIDENTIFIER
		,ParentCrowdId INT
		,ChildCrowdId INT DEFAULT(0)
		,ParentDestination VARCHAR(3)
		,ChildDestination VARCHAR(3)
		,IsSameDestination BIT DEFAULT(0)
		,IsUpdated BIT DEFAULT(0)
		,IsChecked BIT DEFAULT(0)
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
	
	INSERT INTO #SaveTripMapping
	(
		ChildSaveTripId
		,ParentSaveTripId		
	)
	SELECT tripSavedKey
	,parentSaveTripKey  
	FROM TripSaved 
	WHERE parentSaveTripKey IS NOT NULL
	
	SET @incrementCount = 1
	SET @countToExecute = (SELECT COUNT(ChildSaveTripId) FROM #SaveTripMapping)
	
	--BUILD TABLE FOR THOSE RECORDS WHICH HAS A PARENT SAVE TRIP ID
	WHILE (@incrementCount <= @countToExecute)  
	BEGIN
		SELECT TOP 1 @SaveTripMappingId	= SaveTripMappingId
		,@SavetripId = ChildSaveTripId
		,@parentSavetripId = ParentSaveTripId
		FROM #SaveTripMapping
		WHERE IsUpdated = 0
		
		SELECT TOP 1 @TripRequestKey = tripRequestKey 
		FROM Trip 
		WHERE tripSavedKey = @parentSavetripId
		
		SELECT @CrowdId = CrowdId
		FROM TripSaved
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
		
		UPDATE #SaveTripMapping
		SET ParentCrowdId = ISNULL(@CrowdId, 0)
		,ParentDestination = @DestinationCity
		,ChildDestination = @childDestinationCity
		,IsSameDestination = 
		(
			CASE
				WHEN @DestinationCity = @childDestinationCity 
				THEN 1
				ELSE 0
			END
		)
		WHERE SaveTripMappingId = @SaveTripMappingId
		
		UPDATE #SaveTripMapping
		SET IsUpdated = 1
		WHERE SaveTripMappingId = @SaveTripMappingId
		
		SET @incrementCount += 1
		
	END
	--BUILD TABLE
	
	UPDATE #SaveTripMapping
	SET IsUpdated = 0
	
	SET @recursiveIncrementCount = 1
	SET @recursiveCountToExecute = 1	
	SET @countToExecute = (SELECT COUNT(ChildSaveTripId) FROM #SaveTripMapping)
		
	WHILE (@recursiveIncrementCount <= @recursiveCountToExecute)
	BEGIN
				
		WHILE (@incrementCount <= @countToExecute)
		BEGIN
			
			--PICK ONLY THOSE RECORDS WHOSE isUpdated AND IsChecked IS ZERO
			SELECT TOP 1 @SaveTripMappingId = SaveTripMappingId
			,@SavetripId = ChildSaveTripId
			,@parentSavetripId = ParentSaveTripId
			,@isSameDestination = IsSameDestination
			,@parentCrowdId = ISNULL(ParentCrowdId, 0)
			,@childDestinationCity = ChildDestination
			FROM #SaveTripMapping
			WHERE isUpdated = 0
			AND IsChecked = 0
						
			--PRINT 'parentCrowdId: ' + CONVERT(VARCHAR,@parentCrowdId)
			--CONDITION FOR THOSE RECORDS WHOSE PARENT HAVE A PARENT CROWD ID
			IF(@parentCrowdId > 0)
			BEGIN
				/*IF THE PARENT-CHILD DESTINATION IS SAME THEN ASSINGN THE 
				PARENT CROWD ID TO CHILD*/				
				IF(@isSameDestination = 1)
				BEGIN
					UPDATE TripSaved
					SET CrowdId = @parentCrowdId
					WHERE tripSavedKey = @SavetripId
					
					/*UPDATE THE TEMPORARY TABLE WITH CROWD ID WHOSE PARENT SAVE TRIP IS 
					EQUAL TO THE CURRENT CHILD SAVE TRIP*/
					UPDATE #SaveTripMapping
					SET ParentCrowdId = @parentCrowdId
					WHERE ParentSaveTripId = @SavetripId
					
					--THIS STATEMENT IS NOT NEEDED. ITS JUST TO SEE THE UPDATED VALUE AT THE END
					UPDATE #SaveTripMapping
					SET ChildCrowdId = @parentCrowdId
					WHERE SaveTripMappingId = @SaveTripMappingId
					
				END
				/*IF PARENT-CHILD DESTINATION ARE DIFFERENT CREATE NEW CROWD ID AND
				ASSIGN IT TO THE CHILD*/
				ELSE
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
					
					/*UPDATE THE TEMPORARY TABLE WITH CROWD ID WHOSE PARENT SAVE TRIP IS 
					EQUAL TO THE CURRENT CHILD SAVE TRIP*/
					UPDATE #SaveTripMapping
					SET ParentCrowdId = @CrowdId
					WHERE ParentSaveTripId = @SavetripId
					
					--THIS STATEMENT IS NOT NEEDED. ITS JUST TO SEE THE UPDATED VALUE AT THE END
					UPDATE #SaveTripMapping
					SET ChildCrowdId = @CrowdId
					WHERE SaveTripMappingId = @SaveTripMappingId
					
				END
				
				/*SET IsUpdated AND  IsChecked TO 1 SO THAT NEXT TIME THE 
				SAME RECORD IS NOT PICKED UP FOR LOOPING*/
				UPDATE #SaveTripMapping
				SET IsUpdated = 1
				,IsChecked = 1
				WHERE SaveTripMappingId = @SaveTripMappingId
				
			END
			--WHEN PARENT CROWD ID IS 0
			ELSE
			BEGIN
				--SET IsChecked TO 0 SO THAT THE SAME RECORD IS NOT PICKED UP FOR THE NEXT LOOP				
				UPDATE #SaveTripMapping
				SET IsChecked = 1
				WHERE SaveTripMappingId = @SaveTripMappingId
			END		
			
			SET @incrementCount += 1
		END
		
		/*UPDATE THOSE RECORDS WHICH DOESN'T HAVE A PARENT CROWD ID
		THIS MAKES THE RECORD ELIGIBLE FOR NEXT LOOP*/
		UPDATE #SaveTripMapping
		SET IsChecked = 0
		WHERE IsUpdated = 0
		
		SET @countToExecute = (SELECT COUNT(ChildSaveTripId) 
		FROM #SaveTripMapping 
		WHERE IsUpdated = 0
		AND IsChecked = 0)
		
		--PRINT 'countToExecute: ' + CONVERT(VARCHAR,@countToExecute)
		/*CHECK IF THERE ARE MORE RECORDS HAVING PARENT CROWD ID ZERO.
		IF RECORD PRESENT INCREASE THE RECURSIVE COUNT FOR ANOTHER LOOP*/
		IF(@countToExecute > 0)
		BEGIN
			SET @recursiveCountToExecute += 1
		END
		
		SET @recursiveIncrementCount += 1
		SET @incrementCount = 1
		
	END
	
	--TRIP DETAILS UPDATE
	INSERT INTO @TripDetails
	(
		TripSavedKey
	)
	SELECT DISTINCT tripSavedKey 
	FROM TripDetails
	
	SET @countToExecute = (SELECT COUNT(TripDetailsId) FROM @TripDetails)
	SET @incrementCount = 1
	
	--UPDATE TripDetails TABLE WITH CrowdId
	WHILE(@incrementCount <= @countToExecute)
	BEGIN
		SELECT TOP 1 @tripDetailsId = TripDetailsId
		,@SavetripId = TripSavedKey
		FROM @TripDetails
		WHERE IsUpdated = 0
		
		SELECT @CrowdId = CrowdId 
		FROM TripSaved
		WHERE tripSavedKey = @SavetripId
		
		UPDATE TripDetails
		SET CrowdId = @CrowdId
		WHERE tripSavedKey = @SavetripId
		
		UPDATE @TripDetails
		SET IsUpdated = 1
		WHERE TripDetailsId = @tripDetailsId
		
		SET @incrementCount += 1
	END
	
	SELECT * FROM #SaveTripMapping WHERE IsUpdated = 0
    SELECT * FROM #SaveTripMapping
    
    DROP TABLE #SaveTripMapping
    
END

GO
