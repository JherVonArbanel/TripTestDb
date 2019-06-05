SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spInsertSabreSession_SessionIdOutput] 
(
	@ConnectionID	INT,
	@Token			NVARCHAR(256),
	@Status			NVARCHAR(16),
	@LastAccessDate DATETIME,
	@ConversationId NVARCHAR(64),
	@AAAPCC VARCHAR(4) = '',
	@CreationDate DATETIME = GETUTCDATE,
	@SessionID int Output -- Returns Session Id
	
)
AS

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE


	SET NOCOUNT ON

--BEGIN TRANSACTION 	
BEGIN Tran sabresession;


	EXEC sp_getapplock @Resource = 'InsertSession', 
               @LockMode = 'Exclusive',@LockOwner = 'Transaction';
               
               
    DECLARE @maxSessionCount AS INT 
	SELECT @maxSessionCount =  MaximumSession  FROM SabreConnection where ConnectionID =@ConnectionID      
            
	IF(SELECT COUNT(*) FROM SabreSession where ConnectionID =@ConnectionID  ) <  @maxSessionCount
	Begin
	INSERT INTO [SabreSession] 
	(
		--[SessionID],
		[ConnectionID],
		[Token],
		[Status],
		[LastAccessDate],
		[ConversationId],
		[AAAPCC],
		[CreationDate]
	) VALUES (
		--@SessionID,
		@ConnectionID,
		@Token,
		@Status,
		@LastAccessDate,
		@ConversationId,
		@AAAPCC,
		@CreationDate
	)
	End
	
	
	Select @SessionID = SCOPE_IDENTITY()
	--EXEC sp_releaseapplock @Resource = 'InsertSession';	

--Commit Tran SabreSession

--Begin Tran SessionLock

	--EXEC sp_getapplock @Resource = 'InsertSessionLock', 
 --              @LockMode = 'Exclusive',@LockOwner = 'Transaction';
	
	
	
	IF(SELECT COUNT(*) FROM SabreSession where ConnectionID =@ConnectionID  )>=  @maxSessionCount 
	BEGIN
	EXEC [InsertsessionLock] @ConnectionID  
	END
	
	--EXEC sp_releaseapplock @Resource = 'InsertSessionLock';	
	
--Commit Tran SessionLock

EXEC sp_releaseapplock @Resource = 'InsertSession';	
Commit Tran SabreSession

If @@ERROR <> 0
Begin
	Rollback Tran Sabresession
	Rollback Tran SessionLock
	
	
End	
--COMMIT TRANSACTION;
GO
