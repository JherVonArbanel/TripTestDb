SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 25th June 2014
-- Description:	Updates/Insert PassengerAge table for those trips whose pax age are missing
-- =============================================
--EXEC USP_UpdateMissingPaxAge 5
CREATE PROCEDURE [dbo].[USP_UpdateMissingPaxAge]
	
	@siteKey INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--DECLARATION
	DECLARE @countToExecute INT = 0
			,@incrementCount INT = 1
			,@tmp_TripId INT
			,@tripKey INT
			,@tripRequestKey INT
			,@tripChildCount INT
			,@tripInfantCount INT
			,@tripYouthCount INT
			,@tripInfantWithSeatCount INT
			,@passengerAgeKey INT
			
	CREATE TABLE #Tmp_Trip
	(
		Tmp_TripId INT IDENTITY (1,1)
		,TripKey INT
		,TripRequestKey INT
		,TripChildCount INT
		,TripInfantCount INT
		,TripYouthCount INT
		,TripInfantWithSeatCount INT
		,IsUpdated BIT DEFAULT (0)
	)
	
	INSERT INTO #Tmp_Trip
	(
		TripKey
		,TripRequestKey
		,TripChildCount
		,TripInfantCount
		,TripYouthCount
		,TripInfantWithSeatCount
	)
	SELECT 
		TripKey
		,TripRequestKey
		,ISNULL(tripChildCount, 0)
		,ISNULL(tripInfantCount, 0)
		,ISNULL(tripYouthCount, 0)
		,ISNULL(tripInfantWithSeatCount, 0)
	FROM Trip 
	WHERE siteKey = @siteKey 
	AND ISNULL(tripChildCount,0) > 0
	OR ISNULL(tripInfantCount,0) > 0
	OR ISNULL(tripYouthCount,0) > 0
	OR ISNULL(tripInfantWithSeatCount,0) > 0
	
	--SELECT * FROM #Tmp_Trip
	
	DELETE FROM #Tmp_Trip 
	WHERE TripRequestKey IN
	(  
		SELECT TripRequestKey FROM PassengerAge 
		WHERE TripRequestKey 
		IN 
		(
			SELECT TripRequestKey
			FROM #Tmp_Trip
		)
		AND TripKey IS NULL
	)
	
	DELETE FROM #Tmp_Trip 
	WHERE TripKey IN
	(
		SELECT TripKey FROM PassengerAge
		WHERE TripKey IN
		(
			SELECT TripKey
			FROM #Tmp_Trip
		)
		AND ISNULL(PassengerAge, 0) <> 0
	)
	
	DELETE FROM #Tmp_Trip
	WHERE TripRequestKey IS NULL
	
	SET @countToExecute = (SELECT COUNT(Tmp_TripId) FROM #Tmp_Trip)
	--SELECT * FROM #Tmp_Trip
	
	 --LOOP FOR #Tmp_Trip
	WHILE (@incrementCount <= @countToExecute)  
	BEGIN
		
		SELECT TOP 1 
				@tmp_TripId = Tmp_TripId
			   ,@tripKey = TripKey
			   ,@tripRequestKey = TripRequestKey
			   ,@tripChildCount = TripChildCount
			   ,@tripInfantCount = TripInfantCount
			   ,@tripYouthCount = TripYouthCount
			   ,@tripInfantWithSeatCount = TripInfantWithSeatCount
		FROM #Tmp_Trip
		WHERE IsUpdated = 0
		
		IF EXISTS(SELECT 1 FROM PassengerAge 
				  WHERE TripKey = @tripKey 
				  AND TripRequestKey = @tripRequestKey)
		--UPDATE PassengerAge
		BEGIN
			
			--CHILD AGE UPDATE
			IF(@tripChildCount > 0)
			BEGIN
				SET @passengerAgeKey = (SELECT PassengerAgeKey FROM PassengerAge 
										WHERE TripKey = @tripKey 
										AND TripRequestKey = @tripRequestKey
										AND PassengerTypeKey = 2)
				
				UPDATE PassengerAge 
				SET PassengerAge = 5
				WHERE PassengerAgeKey = @passengerAgeKey
			END
			
			--INFANT AGE UPDATE
			IF(@tripInfantCount > 0)
			BEGIN
				SET @passengerAgeKey = (SELECT PassengerAgeKey FROM PassengerAge 
										WHERE TripKey = @tripKey 
										AND TripRequestKey = @tripRequestKey
										AND PassengerTypeKey = 3)
				
				UPDATE PassengerAge 
				SET PassengerAge = 1
				WHERE PassengerAgeKey = @passengerAgeKey
			END
			
			--YOUTH AGE UPDATE
			IF(@tripYouthCount > 0)
			BEGIN
				SET @passengerAgeKey = (SELECT PassengerAgeKey FROM PassengerAge 
										WHERE TripKey = @tripKey 
										AND TripRequestKey = @tripRequestKey
										AND PassengerTypeKey = 6)
				
				UPDATE PassengerAge 
				SET PassengerAge = 15
				WHERE PassengerAgeKey = @passengerAgeKey
			END
			
			--INFANT WITH SEAT AGE UPDATE
			IF(@tripInfantWithSeatCount > 0)
			BEGIN
				SET @passengerAgeKey = (SELECT PassengerAgeKey FROM PassengerAge 
										WHERE TripKey = @tripKey 
										AND TripRequestKey = @tripRequestKey
										AND PassengerTypeKey = 7)
				
				UPDATE PassengerAge 
				SET PassengerAge = 1
				WHERE PassengerAgeKey = @passengerAgeKey
			END
			
		END
		--INSERT PassengerAge
		ELSE
		BEGIN
			
			--CHILD AGE INSERT
			IF(@tripChildCount > 0)
			BEGIN
				
				INSERT INTO PassengerAge
				(
					TripRequestKey
					,TripKey
					,PassengerTypeKey
					,PassengerAge
				)
				VALUES
				(
					@tripRequestKey
					,@tripKey
					,2
					,5
				)				
				
			END
			
			--INFANT AGE INSERT
			IF(@tripInfantCount > 0)
			BEGIN
			
				INSERT INTO PassengerAge
				(
					TripRequestKey
					,TripKey
					,PassengerTypeKey
					,PassengerAge
				)
				VALUES
				(
					@tripRequestKey
					,@tripKey
					,3
					,1
				)
				
			END
			
			--YOUTH AGE INSERT
			IF(@tripYouthCount > 0)
			BEGIN
			
				INSERT INTO PassengerAge
				(
					TripRequestKey
					,TripKey
					,PassengerTypeKey
					,PassengerAge
				)
				VALUES
				(
					@tripRequestKey
					,@tripKey
					,6
					,15
				)
				
			END
			
			--INFANT WITH SEAT AGE INSERT
			IF(@tripInfantWithSeatCount > 0)
			BEGIN
				
				INSERT INTO PassengerAge
				(
					TripRequestKey
					,TripKey
					,PassengerTypeKey
					,PassengerAge
				)
				VALUES
				(
					@tripRequestKey
					,@tripKey
					,7
					,1
				)
				
			END
		END
		
		UPDATE #Tmp_Trip SET IsUpdated = 1
		WHERE Tmp_TripId = @tmp_TripId
		
		SET  @incrementCount += 1
	END
	--WHILE LOOP ENDS HERE
	
	DROP TABLE #Tmp_Trip
	
END

GO
