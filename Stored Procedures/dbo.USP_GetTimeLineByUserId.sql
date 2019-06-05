SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 15-01-2016 14:25pm
-- Description:	Getting types of time lines for userkey
-- =============================================
-- Exec USP_GetTimeLineByUserId 561945 , 30, 1 ,''
CREATE PROCEDURE [dbo].[USP_GetTimeLineByUserId] 

	@userKey bigint,
    @limit int = 30,
    @pageNumber int =1,
    @atUserKeys varchar(max) = null
AS
BEGIN

	--*********** Insert @ userkeys in temp***********
	Declare @UserKeys table
	(UserKey int)
	
	Declare @isLoggeduser bit = 0
	
	INSERT INTO @UserKeys
	(UserKey)
	SELECT * From dbo.ufn_DelimiterToTable(@atUserKeys,',')

	If NOt Exists(Select * from @UserKeys)
	BEGIN
		SET @isLoggeduser = 1
	
		INSERT INTO @UserKeys
		(UserKey)		
		SELECT @userKey
	END

	
	CREATE TABLE #TmpTimeLine
	(  
	   [timeLineKey] [int] NOT NULL,  
       [userKey] [bigint] NOT NULL,  
       [timeLineGroupKey] [int] NOT NULL,  
       [jsonData]  [nvarchar](MAX) NOT NULL,  
       [isRead] [bit] NULL,
       [tripKey] [bigint] NULL,
       [tripSavedKey] [nvarchar](200) NULL,
       [tripCreatorImage] [nvarchar](200) NULL,
       [createdDate] [datetime] NOT NULL,
       [associatedJSONData]  [nvarchar](MAX) NULL,
       [savings] [float] NULL,
       [UserName] [nvarchar](200) NULL,
       [LikeCount] [bigint] NULL,
       [CommentsCount] [bigint] NULL,
       [IsLike] [int] NULL,
       [loggedInUserRelation] [int] NULL,
       [isExpired] [bit] NULL,
       [noOfFollowers] [bigint] DEFAULT 0,
       [crowdId] [bigint] DEFAULT 0,
       [LoggedInUserKey] [bigint] DEFAULT 0,
       [DestinationCode] [nvarchar](200) NULL,
       [GroupName] VARCHAR(100) NULL,
       [GroupDescription] VARCHAR(200) NULL,
       [GroupImage] [IMAGE] NULL,
       [MembersCount] INT NULL,
       [IsImageDataAvailable] bit
	) 


	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName,LoggedInUserKey)
		SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,0,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName, @userKey
		
		FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		where timeLineGroupKey=1 and t.userKey IN (Select UserKey From @UserKeys) ORDER BY createdDate DESC

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount,IsLike ,LoggedInUserKey,DestinationCode)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName   as UserName, TL.LikeCount, CM.CommentsCount ,( select COUNT(1) from trip..TripLike tpl where tpl.tripKey=T.tripKey AND tpl.userKey=@userKey)as IsLike, @userKey,TD.tripTo
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
		 LEFT OUTER JOIN (Select tripKey 
							, COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
						 , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0   
	 
       INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
       INNER JOIN TRIP..TripDetails TD ON TP.tripKey=TD.tripKey
   		  where timeLineGroupKey=2  ORDER BY T.createdDate DESC

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName,LikeCount,CommentsCount,IsLike, LoggedInUserKey,DestinationCode)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings ,U.userFirstName   as UserName,LikeCount,CommentsCount, ( select COUNT(1) from trip..TripLike tpl where tpl.tripKey=T.tripKey AND tpl.userKey=@userKey)as IsLike, @userKey,TD.tripTo
		 FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
	   LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0    
      INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
      INNER JOIN TRIP..TripDetails TD ON TP.tripKey=TD.tripKey
   		 where timeLineGroupKey=3 and T.tripKey > 0  ORDER BY T.createdDate DESC
	
	IF @isLoggeduser = 1 
	BEGIN
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName, LikeCount, CommentsCount,IsLike, LoggedInUserKey,DestinationCode)
	  --SELECT timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings 
		 --FROM Trip..TimeLine where timeLineGroupKey=4 and userKey=@UserKeys and showAlert =1 and savings > 0 ORDER BY createdDate DESC
			  SELECT  timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,null,savings,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName, TL.LikeCount, CM.CommentsCount,( select COUNT(1) from trip..TripLike tpl where tpl.tripKey=T.tripKey AND tpl.userKey=@userKey)as IsLike, @userKey,TD.tripTo
		 FROM Trip..TimeLine T
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 		 		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0 
      INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
      INNER JOIN TRIP..TripDetails TD ON TP.tripKey=TD.tripKey
   		 where timeLineKey in(		 		 
		 Select timeLineKey FROM(
					SELECT ROW_NUMBER() OVER (PARTITION BY userKey,timeLineGroupKey,tripKey ORDER BY createdDate DESC) AS ID,userKey,timeLineGroupKey,tripKey, savings,timeLineKey
					FROM [Trip].[dbo].[TimeLine] WHERE timeLineGroupKey=4 and userKey IN (Select UserKey From @UserKeys) and showAlert =1 and savings > 0 
					) TM WHERE TM.ID<2 					
					)			
	ORDER BY T.createdDate DESC 
	END 
	
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount,IsLike, LoggedInUserKey,DestinationCode)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	   (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName   as UserName , TL.LikeCount, CM.CommentsCount , ( select COUNT(1) from trip..TripLike tpl where tpl.tripKey=T.tripKey AND tpl.userKey=@userKey)as IsLike, @userKey,TD.tripTo
		 FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		  INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
	   LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0   
      INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
      INNER JOIN TRIP..TripDetails TD ON TP.tripKey=TD.tripKey
   		 WHERE timeLineGroupKey=5 ORDER BY T.createdDate DESC
	  
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName, LoggedInUserKey)
	  SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,0 ,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName, @userKey 
	  FROM Trip..TimeLine T
	  INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		WHERE timeLineGroupKey=6 and T.userKey IN (Select UserKey From @UserKeys) ORDER BY createdDate DESC
		 
		 
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount,IsLike, LoggedInUserKey,DestinationCode)
	  SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName,LikeCount,CommentsCount,( select COUNT(1) from trip..TripLike tpl where tpl.tripKey=T.tripKey AND tpl.userKey=@userKey)as IsLike, @userKey,TD.tripTo 
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		 INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0   
       INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
       INNER JOIN TRIP..TripDetails TD ON TP.tripKey=TD.tripKey
   		 WHERE timeLineGroupKey=7 ORDER BY T.createdDate DESC
		 
		 
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName, LoggedInUserKey)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings , U.userFirstName  as userName, @userKey
	 FROM Trip..TimeLine T 
	 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
	 where timeLineGroupKey=8 and T.userKey IN (Select UserKey From @UserKeys)  ORDER BY createdDate DESC	
	 
	 --Added for New FriendGroups Timeline(tripKey is actually a groupKey)
	 IF(@atUserKeys = '' OR @atUserKeys IS NULL)
	 BEGIN
		 INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName, LoggedInUserKey)
		 SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings , U.userFirstName  AS userName, @userKey
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		 WHERE timeLineGroupKey=9 and T.userKey IN (SELECT UserKey FROM @UserKeys)  ORDER BY createdDate DESC
	 END
	 ELSE
	 BEGIN
		INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName, LoggedInUserKey)
		 SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings , U.userFirstName  AS userName, @userKey
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		 INNER JOIN (SELECT GroupKey FROM vault..FriendsGroupMembers WHERE UserKey = @userKey AND Status = 1) tmp ON tmp.GroupKey = T.tripKey
		 WHERE timeLineGroupKey=9 and T.userKey IN (SELECT UserKey FROM @UserKeys) ORDER BY createdDate DESC
	 END
	 
	 --Updating GroupName,Description,GroupImage and Members
	 UPDATE TMP SET TMP.GroupName = TG.Name,TMP.GroupDescription = TG.Description,TMP.GroupImage = TG.GroupImage,TMP.MembersCount = TG.Members FROM #TmpTimeLine TMP 
	 INNER JOIN (SELECT FG.GroupKey,FG.Name,FG.Description,FG.GroupImage,FGM.Members FROM vault..FriendsGroups FG INNER JOIN 
				(SELECT GroupKey,COUNT(UserKey) AS Members FROM vault..FriendsGroupMembers WHERE Status = 1 GROUP BY GroupKey) AS FGM ON FG.GroupKey = FGM.GroupKey) TG
	 ON TG.GroupKey = TMP.tripKey
		
	update TT
	 SET TT.loggedInUserRelation = (CASE WHEN TS.CrowdId > 0 THEN 1 ELSE 0 END) 
	FROM  #TmpTimeLine TT
	INNER JOIN Trip..Trip TP ON TP.tripKey = TT.tripKey 
	INNER JOIN Trip..Trip TP1 ON TP1.tripSavedKey = TP.tripSavedKey AND TP1.IsWatching=1 AND TP1.userKey=@userKey 
   	LEFT OUTER JOIN Trip..TripSaved TS ON TS.tripSavedKey = TP1.tripSavedKey	
   	
   	
   	update TT set TT.isExpired = 1 FROM #TmpTimeLine TT 
   	INNER JOIN Trip..Trip TP ON TP.tripKey = TT.tripKey
   	 WHERE TP.startDate < GETDATE()
   	--Removing system generated trips and purchased trips
    DELETE T FROM #TmpTimeLine T
   	 INNER JOIN Trip..Trip TP ON T.tripKey = TP.tripKey AND T.timeLineGroupKey != 9  AND (TP.isUserCreatedSavedTrip = 0 OR TP.tripStatusKey in (1,4,5,15)) 
   	 
   	 UPDATE TT SET TT.crowdId = TS.CrowdId
   	 FROM #TmpTimeLine TT JOIN Trip T ON TT.tripKey = T.tripKey
   	 JOIN TripSaved TS ON TS.tripSavedKey = T.tripSavedKey
   	 
   	 UPDATE TT SET TT.noOfFollowers = (SELECT COUNT(distinct(T.userKey)) FROM Trip T 
	 JOIN TripSaved TS ON TS.tripSavedKey = T.tripSavedKey
	 WHERE T.IsWatching = 1 AND Ts.crowdId = TT.crowdId)
	 FROM #TmpTimeLine TT 
	
	UPDATE TT SET TT.IsImageDataAvailable = (CASE WHEN UM.UserImageData IS NOT NULL THEN 1 ELSE 0 END) 
		FROM loyalty.dbo.UserMap UM  
	 JOIN #TmpTimeLine TT ON TT.userKey = UM.UserId
	
	
	UPDATE TT SET TT.tripSavedKey = (CASE WHEN (TS.parentSaveTripKey IS NOT NULL AND TT.timeLineGroupKey != 4) THEN TS.parentSaveTripKey ELSE TS.tripSavedKey END)
	FROM Trip T JOIN #TmpTimeLine TT ON T.tripKey = TT.tripKey AND TT.tripKey >0 
	JOIN TripSaved TS ON TS.tripSavedKey = T.tripSavedKey
	
	UPDATE TT SET TT.tripCreatorImage = 
	(CASE WHEN UM.UserImageData IS NOT NULL THEN 'user/image/' + CAST(UM.UserId AS Varchar) ELSE UM.ImageUrl END) 
		FROM  Trip T
	 JOIN #TmpTimeLine TT ON T.tripSavedKey = TT.tripSavedKey AND TT.tripKey >0  
	JOIN loyalty.dbo.UserMap UM  ON UM.UserId = T.userKey 
	 
	If @isLoggeduser = 1
	BEGIN
		SELECT * FROM 
	    (SELECT  ROW_NUMBER() OVER ( ORDER BY CreatedDate DESC ) AS RowNum, * FROM #TmpTimeLine
	    ) AS RowNumbering
	    WHERE RowNum >= @limit * (@pageNumber - 1) + 1 AND RowNum <= @pageNumber * @limit
	    
	    Order BY RowNum	 
	END		 	
	
	ELSE
	BEGIN	 		 
	     
		  SELECT * FROM 
			(SELECT  ROW_NUMBER() OVER ( ORDER BY CreatedDate DESC ) AS RowNum, * FROM #TmpTimeLine
			Where jsonData like Case when CHARINDEX('isFriendAlert',jsonData) > 0 Then '%"isFriendAlert": false%' else '%' end --- Added to show only selected users feeds but not their friends feeds
			) AS RowNumbering
			WHERE RowNum >= @limit * (@pageNumber - 1) + 1 AND RowNum <= @pageNumber * @limit
		    
			Order BY RowNum	 
	END
	  DROP TABLE #TmpTimeLine
  
END
GO
