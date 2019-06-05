SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- exec USP_GetFollowersBucketListForUser 562806, 'BOM'
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetFollowersBucketListForUser] 
	-- Add the parameters for the stored procedure here
	(@userKey INT = 0 , @geoLocation Varchar(50) , @siteKey INT =0 )
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @tbl TABLE (userFirstName varchar(255), imageUrl varchar(255), userKey INT , userLastName varchar(255), followerCount INT DEFAULT 0 , followingCount INT DEFAULT 0, selectionType INT, homeCity varchar(50) , isFollowing bit Default 0 )
	
	DECLARE @countryCode varchar(50) = null;
	
	insert into @tbl (userKey, userFirstName,userLastName, selectionType, homeCity)
	Select U.userKey, U.userFirstName, U.userLastName , 1, AL.CityName
	FROM vault..[User] U
	INNER JOIN vault..AirPreference AR ON U.userKey = AR.userKey  
	INNER JOIN trip..AirportLookup AL ON AL.AirportCode = AR.originAirportCode
	WHERE AR.originAirportCode = @geoLocation AND U.siteKey = @siteKey
	
	select @countryCode = AL.CountryCode from  trip..AirportLookup AL WHERE AL.AirportCode = @geoLocation
	
	insert into @tbl (userKey, userFirstName,userLastName, selectionType, homeCity)
	Select U.userKey, U.userFirstName, U.userLastName , 2, AL.CityName
	FROM vault..[User] U
	INNER JOIN vault..AirPreference AR ON U.userKey = AR.userKey  
	INNER JOIN trip..AirportLookup AL ON AL.AirportCode = AR.originAirportCode
	WHERE AL.CountryCode = @countryCode AND U.siteKey = @siteKey AND U.userKey not in ( select userKey from @tbl)
	
	update T SET T.followingCount = TEMP.uCount
	FROM 
	(SELECT Count(UF.UserId) as uCount ,UF.FollowerId
	FROM Loyalty..UserFollowers UF WHERE UF.FollowerId IN (SELECT userKey FROM  @tbl) GROUP BY UF.FollowerId ) TEMP
	INNER JOIN @tbl T ON T.userKey = TEMP.FollowerId

	update T SET T.followerCount = TEMP.uCount
	FROM 
	(SELECT COUNT(UF.FollowerId) as uCount ,UF.UserId
	FROM Loyalty..UserFollowers UF WHERE UF.UserId in (SELECT userKey FROM  @tbl) GROUP BY UF.UserId) TEMP
	INNER JOIN @tbl T ON T.userKey = TEMP.UserId
	
	update T SET T.isFollowing = 1 
	FROM Loyalty..UserFollowers UF INNER JOIN 
	@tbl T ON UF.UserId = T.userKey
	WHERE UF.FollowerId = @userKey
	
	UPDATE T      
	  SET       
	   T.imageUrl = (CASE WHEN (UM.ImageURL ='') THEN (CASE WHEN U.userGender ='M' THEN 'images/default-male-dp.jpg' ELSE 'images/default-female-dp.jpg' END) ELSE ISNULL(UM.ImageURL,'') END)
	  FROM       
	   @tbl T    
	  INNER JOIN       
	   Loyalty..UserMap UM ON T.userKey = UM.UserId  
	    INNER JOIN vault..[User] U ON T.userKey = U.userKey
   
    -- Insert statements for procedure here
	SELECT  * from @tbl WHERE (followerCount > 0 AND followingCount >0) AND userKey != @userKey 
	ORDER BY selectionType ASC, followerCount DESC --(followerCount+followingCount) DESC 
END
GO
