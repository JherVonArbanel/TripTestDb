SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,28-11-2016>
-- Description:	<Description,,To insert and get the user chat steam key>
-- EXEC USP_GetUserChartStreamKey 3, 4
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetUserChatStreamKey] 
	-- Add the parameters for the stored procedure here
	@fromUserkey	bigint,  
	@toUserkey		bigint,
	@streamKey	UNIQUEIDENTIFIER =NULL    
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
--SELECT @fromUserKey = 3, @toUserKey = 4
	
	DECLARE @newStream UNIQUEIDENTIFIER, @currentDate DATETIME 
	DECLARE @unreadCount INT ;
	SET @unreadCount = 0 ;
	
	SET @newStream = NEWID()
	SET @currentDate=GETDATE()
	
	SELECT @streamKey=chatStreamKey, @unreadCount = readCount FROM UserChatMapping
	WHERE fromUserKey=@fromUserkey AND toUserKey=@toUserkey

	
	IF @streamKey IS NULL --OR @streamKey = ''    
	BEGIN  
		
		INSERT INTO UserChatMapping VALUES(@fromUserkey,@toUserkey,@newStream,@currentDate,0)
		INSERT INTO UserChatMapping VALUES(@toUserkey,@fromUserkey,@newStream,@currentDate,0)
		
		SET @streamKey = @newStream 
		
	END
	
	SELECT @streamKey as StreamKey, @unreadCount as UnreadCount
	
END
GO
