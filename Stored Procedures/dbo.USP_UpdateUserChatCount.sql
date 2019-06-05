SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Rohita Patel>
-- Create date: <Create Date,,28-11-2016>
-- Description:	<Description,,To insert and get the user chat steam key>
-- EXEC [USP_UpdateUserChatCount] 560799, 561452,1
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateUserChatCount] 
	-- Add the parameters for the stored procedure here
	@fromUserkey	bigint,  
	@toUserkey		bigint,	
	@isRead BIT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @unReadCount int
	
	SET @unReadCount = 0	
	
	SELECT @unReadCount=readCount FROM UserChatMapping
	WHERE fromUserKey=@fromUserkey AND toUserKey=@toUserkey

	
	IF @isRead>0
	BEGIN  		
		UPDATE UserChatMapping SET readCount=0 WHERE fromUserKey=@fromUserkey AND toUserKey=@toUserkey			
	END
	ELSE
	BEGIN  		
	UPDATE UserChatMapping SET readCount=@unReadCount+1 WHERE fromUserKey=@fromUserkey AND toUserKey=@toUserkey				
	END
		
END
GO
