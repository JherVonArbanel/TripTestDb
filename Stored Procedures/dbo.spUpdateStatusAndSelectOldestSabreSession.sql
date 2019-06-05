SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spUpdateStatusAndSelectOldestSabreSession] 
(
	@CurrentStatus	NVARCHAR(16), 
	@ToSetStatus	NVARCHAR(16) ,
	@AAAPCC VARCHAR(4) = ''
) 
AS 

	SET NOCOUNT ON
	BEGIN TRANSACTION T1 

	DECLARE @Id [int]
	SELECT @Id = (SELECT TOP 1 SessionId FROM sabresession WITH (XLOCK) WHERE STATUS = '' + @CurrentStatus + '' 
		ORDER BY LastAccessDate ASC)

	IF(@Id IS NULL)
		ROLLBACK TRANSACTION T1
	ELSE
	BEGIN

	UPDATE sabresession SET status = '' + @ToSetStatus + '', AAAPCC = @AAAPCC WHERE SessionId = @Id

	SELECT [SessionID], [ConnectionID], [Token], [Status], [LastAccessDate], [ConversationId],[AAAPCC]
	FROM [SabreSession] 
	WHERE [SessionID] = @Id 
	
	COMMIT TRANSACTION T1
	
END
GO
