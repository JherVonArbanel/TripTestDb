SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[usp_SaveEventAttendee]
(
	@eventKey BIGINT,
	@userKey BIGINT,
	@attendeeEmail VARCHAR(50) = '',
	@attendeeFirstName VARCHAR(50) = '',
	@attendeeLastName VARCHAR(50) = '',
	@attendeeImageUrl VARCHAR(50) = '',
	@isHost BIT = 0,
	@attendeeStatusKey INT = 0,	
	@invitorUserKey BIGINT = 0		
)
AS BEGIN

	IF NOT EXISTS (SELECT 1 FROM EventAttendees WHERE eventKey = @eventKey AND userKey = @userKey AND @userKey <> 0)
	BEGIN
		INSERT INTO EventAttendees
		(
			eventKey,
			userKey,
			attendeeEmail,
			attendeeFirstName,
			attendeeLastName,
			attendeeImageUrl,
			isHost,
			attendeeStatusKey,	
			invitorUserKey,
			creationDate,
			attendeeActionDate
					
		)
		VALUES
		(
			@eventKey,
			@userKey,
			@attendeeEmail,
			@attendeeFirstName,
			@attendeeLastName,
			@attendeeImageUrl,
			@isHost,
			@attendeeStatusKey,	
			@invitorUserKey,
			GETDATE()	,
			GETDATE()
		)

	END
	ELSE
	BEGIN
	
		UPDATE 
			EventAttendees
		SET 
			attendeeStatusKey = @attendeeStatusKey,
			attendeeActionDate = GETDATE()
		WHERE 
			eventKey = @eventKey
		AND 
			userKey = @userKey
	END
END

GO
