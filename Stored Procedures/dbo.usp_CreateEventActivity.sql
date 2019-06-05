SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[usp_CreateEventActivity]
(
	@eventKey BIGINT,
	@activityDate DATETIME,
	@activityDescription VARCHAR(50),
	@userKey BIGINT
)
AS 
BEGIN 

	INSERT INTO EventActivities
	(		
		eventKey,
		activityDate,
		activityDescription,
		userKey,
		creationDate,		
		isDeleted			
	)
	VALUES
	(
		@eventKey,
		@activityDate,
		@activityDescription,
		@userKey,
		GETDATE(),
		0	
	)

END
GO
