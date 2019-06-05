SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 28/Apr/2015
-- Description:	It is used to get notification and alert from Timeline table.
-- Exec USP_GetTimeLine 560812,0,5,'','2015-03-05 15:27:05.000'
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTimeLine]
	-- Add the parameters for the stored procedure here
	@userKey INT,
	@timeLineGroupKey INT,
	@noOfRecords INT = 10,
	@type Varchar(10) = '', -- it is used to get combine group details
	@lastDate DateTime = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--Changed to Add following users alerts too in notifications/alerts 
	--Get all the user id whom the logged user is following
	Declare @FollowingUsers table
	(UserId int)
	
	INSERT INTO @FollowingUsers
	(UserId)
	--SELECT UserId FROM LOYALTY.dbo.UserFollowers WHERE FollowerId = @userKey --Following users
	--UNION ALL
	SELECT @userKey -- logged in users

    -- Insert statements for procedure here
    IF @type = ''
    BEGIN
    IF @timeLineGroupKey = 0 
		BEGIN
			IF @noOfRecords > 0
			BEGIN
					SELECT TOP (@noOfRecords) *
					FROM TimeLine
					WHERE userKey IN (Select UserId From @FollowingUsers)
					AND (@lastDate is null OR createdDate < @lastDate)
					ORDER BY createdDate Desc
			END
            ELSE
            BEGIN
            		SELECT  *
					FROM TimeLine
					WHERE userKey IN (Select UserId From @FollowingUsers)
					AND (@lastDate is null OR createdDate < @lastDate)
					ORDER BY createdDate Desc
            END
		END
    ELSE
		BEGIN
		
		IF @noOfRecords > 0
			BEGIN
					 SELECT TOP (@noOfRecords) *
						FROM TimeLine
						WHERE userKey IN (Select UserId From @FollowingUsers)
						AND timeLineGroupKey = @timeLineGroupKey
						AND (@lastDate is null OR createdDate < @lastDate)
						ORDER BY createdDate Desc
			END
            ELSE
            BEGIN
            		 SELECT  *
					FROM TimeLine
					WHERE userKey IN (Select UserId From @FollowingUsers)
					AND timeLineGroupKey = @timeLineGroupKey
					AND (@lastDate is null OR createdDate < @lastDate)
					ORDER BY createdDate Desc
            END
	   
		END 
    END
    ELSE 
    BEGIN
       IF @type = 'F' -- For My Friends - consider Followers and following
       BEGIN
       
         IF @noOfRecords > 0
			BEGIN
					SELECT TOP (@noOfRecords) *
					FROM TimeLine
					WHERE userKey IN (Select UserId From @FollowingUsers)
					AND timeLineGroupKey IN (1,6)
					AND (@lastDate is null OR createdDate < @lastDate)
					ORDER BY createdDate Desc
			END
            ELSE
            BEGIN
            		SELECT *
					FROM TimeLine
					WHERE userKey IN (Select UserId From @FollowingUsers)
					AND timeLineGroupKey IN (1,6)
					AND (@lastDate is null OR createdDate < @lastDate)
					ORDER BY createdDate Desc
            END
        
       END
       IF @type = 'C'
       BEGIN
       
       IF @noOfRecords > 0
			BEGIN  
			
				SELECT TOP (@noOfRecords) *
				FROM TimeLine
				WHERE userKey IN (Select UserId From @FollowingUsers)
				AND timeLineGroupKey IN (2,5)
				AND (@lastDate is null OR createdDate < @lastDate)
				ORDER BY createdDate Desc
			END
            ELSE
            BEGIN
            		SELECT *
					FROM TimeLine
					WHERE userKey IN (Select UserId From @FollowingUsers)
					AND timeLineGroupKey IN (2,5)
					AND (@lastDate is null OR createdDate < @lastDate)
					ORDER BY createdDate Desc
            END
            
     
       END
    END
    
END
GO
