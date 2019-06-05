SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Anupam Patel
-- Create date: 27/May/2015
-- Description:	It is used for modified read flag of timeline group wise
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateReadFlagofTimeline]
	@timeLineGroupKey INT,
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
    
	Update TimeLine
	SET isRead = 1
	WHERE timeLineGroupKey = @timeLineGroupKey and userKey = @userKey
	
END
GO
