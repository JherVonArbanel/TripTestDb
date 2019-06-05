SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[usp_DeleteEventActivity]
(
	@eventActivityKey BIGINT
)
AS
BEGIN

	DELETE FROM EventActivities
	WHERE eventActivityKey = @eventActivityKey

END
GO
