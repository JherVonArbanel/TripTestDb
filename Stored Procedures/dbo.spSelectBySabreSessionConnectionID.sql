SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spSelectBySabreSessionConnectionID] 
(
	@ConnectionID INT
)
AS

	SET NOCOUNT ON

	SELECT [SessionID], [ConnectionID], [Token], [Status], [LastAccessDate], [ConversationId],[AAAPCC]
	FROM [SabreSession] 
	WHERE [ConnectionID] = @ConnectionID
GO
