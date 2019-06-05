SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 18 February 2015
-- Description:	This procedure is used to update hash tags based on trip id or eventid
-- =============================================
CREATE PROCEDURE [dbo].[usp_updateHashTags]
	@tripid INT = 0,
	@eventid INT = 0,
	@oldHashTagValue NVARCHAR(800),
	@newHashTagValue NVARCHAR(800)
AS
BEGIN
	IF (@eventid > 0)
	BEGIN
		UPDATE
			Trip..triphashtagmapping
		SET
			HashTag = @newHashTagValue
		WHERE
			EventKey = @eventid AND
			HashTag = @oldHashTagValue			
	END
	ELSE IF (@tripid > 0)
	BEGIN
		UPDATE
			Trip..triphashtagmapping
		SET
			HashTag = @newHashTagValue
		WHERE
			TripKey = @tripid AND
			HashTag = @oldHashTagValue			
	END
END
GO
