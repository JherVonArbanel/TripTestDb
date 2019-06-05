SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spSelectBySabreSessionConnectionIDAndStatus] 
(
	@ConnectionID	INT,
	@Status			NVARCHAR(16)
)
AS

	SET NOCOUNT ON

	SELECT [SessionID], [ConnectionID], [Token], [Status], [LastAccessDate], [ConversationId] ,[AAAPCC]
	FROM [SabreSession]
	WHERE [ConnectionID] = @ConnectionID AND [Status] = @Status
GO
