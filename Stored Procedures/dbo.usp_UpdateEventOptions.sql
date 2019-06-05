SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 11th December 2014
-- Description:	This procedure is used to update event options in events table
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateEventOptions]
	@eventId INT,
	@eventViewershipType INT,
	@isInviteFromAttendeeAllowed BIT,
	@isAttendeeActivityEditAllowed BIT,
	@eventDescription Varchar(500), 
	@eventName Varchar(500) = null
AS
BEGIN
	UPDATE 
		[events]
	SET 
		eventViewershipType = @eventViewershipType,
		isInviteFromAttendeeAllowed = @isInviteFromAttendeeAllowed, 
		isAttendeeActivityEditAllowed = @isAttendeeActivityEditAllowed,
		eventDescription = @eventDescription
	WHERE 
		eventkey = @eventId
		
	if(@eventName IS NOT NULL)
	BEGIN
		UPDATE 
			[events]
		SET
			eventName = @eventName
		WHERE 
		eventkey = @eventId
	END
END
GO
