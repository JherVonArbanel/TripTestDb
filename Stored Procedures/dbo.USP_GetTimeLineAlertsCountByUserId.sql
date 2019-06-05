SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Anupam Patel
-- Create date: 26/May/2015
-- Description:	It is used to get count notification and alert user wise.
-- Exec [USP_GetTimeLineAlertsCountByUserId] 560799
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTimeLineAlertsCountByUserId]
	-- Add the parameters for the stored procedure here
	@userKey INT
AS
BEGIN

	SET NOCOUNT ON;
	
	--Changed to Add following users alerts too in notifications/alerts 
	--Get all the user id whom the logged user is following
	--Declare @FollowingUsers table
	--(UserId int)
	
	--INSERT INTO @FollowingUsers
	--(UserId)
	--SELECT UserId FROM LOYALTY.dbo.UserFollowers WHERE FollowerId = @userKey --Following users
	--UNION ALL
	--SELECT @userKey -- logged in users
	
	--Query to get current Newsfeed(DOD) for Price timeLineGroup 07MAY16
	DECLARE @priceCount int
	SELECT @priceCount = COUNT(timeLineKey) FROM ( SELECT ROW_NUMBER() OVER(PARTITION BY userKey,timeLineGroupKey,tripKey ORDER BY createdDate DESC) RN,
					  timeLineKey FROM TimeLine WHERE timeLineGroupKey=4 AND userKey IN (@userKey) AND showAlert =1 AND savings >= 50 ) A WHERE A.RN < 2 
     
	SELECT timeLineGroupKey ,IsRead, COUNT(*) NoOfAlerts
	FROM TimeLine
	WHERE userKey = @userKey AND TimeLineGroupKey != 4
	GROUP BY TimeLineGroupKey, isRead
	UNION ALL
	SELECT timeLineGroupKey ,IsRead, @priceCount AS NoOfAlerts
	FROM TimeLine 
	WHERE userKey = @userKey AND TimeLineGroupKey = 4
	GROUP BY TimeLineGroupKey, isRead
    
END
GO
