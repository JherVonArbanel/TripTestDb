SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Keyur Sheth
-- Create date: 25th November 2014
-- Description:	Proc used to fetch details related to events and trips
-- =============================================
CREATE PROCEDURE [dbo].[GetEventTripDetails]
	@tripId BIGINT = 0,
	@userId BIGINT = 0 
AS
BEGIN
	DECLARE @eventId BIGINT = 0

	DECLARE @isHost AS BIT = 0 
	DECLARE @attendeeStatusKey AS INT = 0 
	DECLARE @isTripWatcher AS BIT = 0
	DECLARE @hostfirstName VARCHAR(50)
	DECLARE @hostlastName VARCHAR(50)
	DECLARE @hostImageUrl VARCHAR(500)
	DECLARE @isEventPrivate AS BIT = 0
	DECLARE @isTripPrivate AS BIT = 0
	DECLARE @attendeeTripKey AS INT = 0

	IF EXISTS (SELECT 1 FROM Trip WITH (NOLOCK) WHERE tripKey = @tripId AND userKey = @userId)
	BEGIN 
		SET @isTripWatcher = 1  
	END
	
	SELECT 
		@eventId = EA.eventKey
	FROM
		EventAttendees EA WITH (NOLOCK)
		LEFT OUTER JOIN AttendeeTravelDetails ATD WITH (NOLOCK)ON EA.eventAttendeeKey = ATD.eventAttendeeKey
	WHERE 
		ATD.attendeeTripKey = @tripId 

	SELECT
		 @isHost = EA.isHost
		,@attendeeStatusKey = EA.attendeeStatusKey		
		,@isEventPrivate = EV.eventViewershipType	
		,@attendeeTripKey = ATD.attendeeTripKey
	FROM
		EventAttendees EA WITH (NOLOCK)
		LEFT OUTER JOIN AttendeeTravelDetails ATD WITH (NOLOCK)ON EA.eventAttendeeKey = ATD.eventAttendeeKey 
		LEFT OUTER JOIN [Events] EV ON EV.eventKey = EA.eventKey
	WHERE 
		EA.userKey = @userId
		AND ATD.attendeeTripKey = @tripId
		
	SELECT @isTripPrivate = tr.privacyType FROM trip..trip tr WHERE tr.tripKey = @tripId

	IF @eventId > 0
	BEGIN
		DECLARE @hostUserId AS BIGINT 
		SELECT @hostUserId = userkey FROM [Events] WITH(NOLOCK) where eventKey = @eventId
		 
		SELECT 
			@hostfirstName = ISNULL(U.userFirstName,'') 
			,@hostlastName = ISNULL(U.userLastName,'') 
			,@hostImageUrl = ISNULL(UM.ImageURL,'')
		FROM 
			vault..[User] U WITH(NOLOCK) 
			LEFT OUTER JOIN Loyalty..UserMap UM WITH(NOLOCK) ON U.userKey = UM.UserId
		WHERE 
			U.userKey = @hostUserId
	END

	SELECT 
		 @isHost AS isHost
		,@attendeeStatusKey AS attendeeStatusKey
		,@isTripWatcher AS isTripWatcher
		,@hostfirstName AS hostFirstName
		,@hostlastName AS hostlastName
		,@hostImageUrl AS hostImageUrl
		,@isEventPrivate AS isEventPrivate
		,@isTripPrivate AS isTripPrivate
		,@attendeeTripKey AS attendeeTripKey
		,@eventId AS eventId
		,@tripId AS tripId
END

GO
