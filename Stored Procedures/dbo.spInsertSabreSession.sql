SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spInsertSabreSession] 
(
	--@SessionID int,
	@ConnectionID	INT,
	@Token			NVARCHAR(256),
	@Status			NVARCHAR(16),
	@LastAccessDate DATETIME,
	@ConversationId NVARCHAR(64),
	@AAAPCC VARCHAR(4) = ''
)
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

BEGIN TRANSACTION;
	SET NOCOUNT ON

	INSERT INTO [SabreSession] 
	(
		--[SessionID],
		[ConnectionID],
		[Token],
		[Status],
		[LastAccessDate],
		[ConversationId],
		[AAAPCC]
	) VALUES (
		--@SessionID,
		@ConnectionID,
		@Token,
		@Status,
		@LastAccessDate,
		@ConversationId,
		@AAAPCC
	)
	
	DECLARE @maxSessionCount AS INT 
	SELECT @maxSessionCount =  MaximumSession  FROM SabreConnection where ConnectionID =@ConnectionID 
	
	IF(SELECT COUNT(*) FROM SabreSession where ConnectionID =@ConnectionID  )>=  @maxSessionCount 
	BEGIN
	EXEC [InsertsessionLock] @ConnectionID  
	END
	
COMMIT TRANSACTION;
GO
