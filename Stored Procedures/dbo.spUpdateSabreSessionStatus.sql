SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spUpdateSabreSessionStatus] 
(
	@SessionID		INT,
	@Status			NVARCHAR(16),
	@IsUpdateTime	BIT,
	@AAAPCC			VARCHAR(4)=''
)
AS
BEGIN
	SET NOCOUNT ON
	--SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
	BEGIN TRANSACTION T1 
	EXEC sp_getapplock @Resource = 'InsertSession', 
               @LockMode = 'Exclusive',@LockOwner = 'Transaction';
	IF @IsUpdateTime = 1
	BEGIN
		UPDATE [SabreSession] 
		SET [Status]		= @Status, 
			[LastAccessDate]= GETDATE(),
			[AAAPCC] = @AAAPCC
		WHERE [SessionID] = @SessionID
	END
	ELSE
	BEGIN
		UPDATE [SabreSession]
		SET [Status] = @Status,
		[AAAPCC] = @AAAPCC	
		WHERE [SessionID] = @SessionID
	END
	
	
	EXEC sp_releaseapplock @Resource = 'InsertSession';	
	COMMIT TRANSACTION T1
END


GO
