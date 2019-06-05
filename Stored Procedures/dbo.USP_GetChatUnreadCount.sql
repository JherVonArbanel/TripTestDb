SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Shrikant Sonawane>
-- Create date: <Create Date,4Jan2017>
-- Description:	<Description,,To get message unread count>
-- EXEC USP_GetChatUnreadCount '562576,562577,562628,562777,561945,562416,561138,562427,562578,562416,562419,562427,562551,562556,562570,562578,560888,561452,561945,562777,562806', 560799
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetChatUnreadCount] 
	@fromUserkeys	varchar(1000),  
	@toUserkey		bigint	
AS
BEGIN
	Declare @userKeys table 
	(userKey bigint)
	
	INSERT INTO @userKeys
	(userKey)
	SELECT * From dbo.ufn_DelimiterToTable(@fromUserkeys,',')
	
	SELECT ISNULL(readCount,0) as unReadCount, UK.userKey 
	FROM @userKeys UK LEFT JOIN UserChatMapping UCM  ON fromUserKey=UK.userKey AND toUserKey=@toUserkey 
	-- WHERE fromUserKey >0 AND toUserKey >0 

END
GO
