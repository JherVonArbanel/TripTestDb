SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 15th May 2014
-- Description:	Create a new crowd or link a crowd
-- =============================================
--EXEC USP_CreateOrLinkCrowd 14111, 248582
CREATE PROCEDURE [dbo].[USP_CreateOrLinkCrowd]
	
	@parentTripKey INT
	,@tripRequestKey INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	--VARIABLE DECLARATION
	DECLARE @destinationCity VARCHAR(3)
			,@crowdId INT
			,@parentTripRequestKey INT
			,@parentDestinationCity VARCHAR(3)
			,@parentTripSavedKey UNIQUEIDENTIFIER
	
	SELECT @destinationCity = CityCode 
	FROM TripRequest TR WITH (NOLOCK)
	INNER JOIN AirportLookup A WITH (NOLOCK) ON TR.tripTo1 = A.AirportCode 
	WHERE tripRequestKey = @tripRequestKey
		
	--WHEN USER CREATES A NEW CROWD
	IF(@parentTripKey = 0)
	BEGIN
			
		INSERT INTO Crowd (crowdDestination)
		VALUES (@destinationCity)
		SELECT @crowdId = SCOPE_IDENTITY()
		
	END
	--WHEN USER FOLLOWS A CROWD
	ELSE
	BEGIN
		
		SELECT @parentTripRequestKey = tripRequestKey
		,@parentTripSavedKey = tripSavedKey 
		FROM Trip WITH (NOLOCK)
		WHERE tripKey = @parentTripKey	
		
		SELECT @parentDestinationCity = CityCode 
		FROM TripRequest TR WITH (NOLOCK)
		INNER JOIN AirportLookup A WITH (NOLOCK) ON TR.tripTo1 = A.AirportCode 
		WHERE tripRequestKey = @parentTripRequestKey
		
		--IF USER DOESN'T CHANGE THE DESTINATION
		IF(@parentDestinationCity = @destinationCity)
		BEGIN
			SET @crowdId = (SELECT CrowdId FROM TripSaved WITH (NOLOCK) 
							WHERE tripSavedKey = @parentTripSavedKey)
		END
		ELSE
		--IF USER CHANGES THE DESTINATION
		BEGIN			
			INSERT INTO Crowd (crowdDestination)
			VALUES (@destinationCity)
			SELECT @crowdId = SCOPE_IDENTITY()
		END		
			
	END
    
    SELECT CrowdId = @crowdId
    
END

GO
