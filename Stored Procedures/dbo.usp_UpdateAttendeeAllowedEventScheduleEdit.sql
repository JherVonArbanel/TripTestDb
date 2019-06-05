SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 20 August 2014
-- Description:	This procedure is used to update is Attendee allowed to edit event schedule
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateAttendeeAllowedEventScheduleEdit]
	@EventId INT,
	@IsAllowed BIT,
	@returnValue INT OUTPUT
AS
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @err INT
	
	BEGIN TRY
		
		UPDATE [Trip]..[Events]
		SET isAttendeeActivityEditAllowed = @IsAllowed
		WHERE eventKey = @EventId
		
		SELECT @err = @@ERROR
		
		IF (@err = 0)
		BEGIN
			SET @returnValue = 1
		END
		ELSE
		BEGIN
			SET @returnValue = 0
		END
		
	END TRY		
	BEGIN CATCH	
	
		SET @returnValue = 0
		
	END CATCH
END
GO
