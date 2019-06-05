SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTimeLineByUserId_shrikant] 
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
	
	DECLARE @FollowerCount TABLE(CrowdId BIGINT, FollowerCount BIGINT)
	
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
       [createdDate] [datetime] NOT NULL,
       [associatedJSONData]  [nvarchar](MAX) NULL,
       [savings] [float] NULL,
       [UserName] [nvarchar](200) NULL,
       [LikeCount] [bigint] NULL,
       [CommentsCount] [bigint] NULL,
       [loggedInUserRelation] [int] NULL,
       [TripFollowerCount] [int] NULL,
       [CrowdId] [bigint] NULL
	) 


	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName)
		SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead, T.tripKey, T.createdDate,null,0,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName 
		FROM Trip..TimeLine T 
		INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		where timeLineGroupKey=1 and t.userKey IN (Select UserKey From @UserKeys) ORDER BY T.createdDate DESC


	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount , CrowdId )
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName   as UserName, TL.LikeCount, CM.CommentsCount, TS.CrowdId
		 FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
		 	   LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0      		 
       INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
       LEFT JOIN TripSaved TS WITH (NOLOCK) ON TP.tripSavedKey = TS.tripSavedKey
   		  where timeLineGroupKey=2  ORDER BY T.createdDate DESC

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName,LikeCount,CommentsCount , CrowdId)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings ,U.userFirstName   as UserName,LikeCount,CommentsCount , TS.CrowdId
		 FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
	   LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0    
      INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
      LEFT JOIN TripSaved TS WITH (NOLOCK) ON TP.tripSavedKey = TS.tripSavedKey
   		 where timeLineGroupKey=3 and T.tripKey > 0  ORDER BY T.createdDate DESC


	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName, LikeCount, CommentsCount ,CrowdId)
	  --SELECT timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings 
		 --FROM Trip..TimeLine where timeLineGroupKey=4 and userKey=@UserKeys and showAlert =1 and savings > 0 ORDER BY createdDate DESC
			  SELECT  timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,null,savings,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName, TL.LikeCount, CM.CommentsCount , TS.CrowdId
		 FROM Trip..TimeLine T
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 		 		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0 
      INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
      LEFT JOIN TripSaved TS WITH (NOLOCK) ON TP.tripSavedKey = TS.tripSavedKey
   		 where timeLineKey in(		 		 
		 Select timeLineKey FROM(
					SELECT ROW_NUMBER() OVER (PARTITION BY userKey,timeLineGroupKey,tripKey ORDER BY createdDate DESC) AS ID,userKey,timeLineGroupKey,tripKey, savings,timeLineKey
					FROM [Trip].[dbo].[TimeLine] WHERE timeLineGroupKey=4 and userKey IN (Select UserKey From @UserKeys) and showAlert =1 and savings > 0 
					) TM WHERE TM.ID<2 					
					)			
	ORDER BY T.createdDate DESC 

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount, CrowdId)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	   (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName   as UserName , TL.LikeCount, CM.CommentsCount , TS.CrowdId
		 FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		  INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
	   LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0   
      INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
      LEFT JOIN TripSaved TS WITH (NOLOCK) ON TP.tripSavedKey = TS.tripSavedKey
   		 WHERE timeLineGroupKey=5 ORDER BY T.createdDate DESC
	  
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName)
	  SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,0 ,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName 
	  FROM Trip..TimeLine T
	  INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		WHERE timeLineGroupKey=6 and T.userKey IN (Select UserKey From @UserKeys) ORDER BY createdDate DESC
		 
		 
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount, CrowdId)
	  SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName,LikeCount,CommentsCount , TS.CrowdId
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		 INNER JOIN @UserKeys UK ON UK.UserKey = T.userKey
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0   
       INNER JOIN Trip..Trip TP ON TP.tripKey = T.tripKey
       LEFT JOIN TripSaved TS WITH (NOLOCK) ON TP.tripSavedKey = TS.tripSavedKey
   		 WHERE timeLineGroupKey=7 ORDER BY T.createdDate DESC
		 
		 
	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings , U.userFirstName  as userName
	 FROM Trip..TimeLine T 
	 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
	 where timeLineGroupKey=8 and T.userKey IN (Select UserKey From @UserKeys)  ORDER BY createdDate DESC		 
		
	update TT
	 SET TT.loggedInUserRelation = (CASE WHEN TS.CrowdId > 0 THEN 1 ELSE 0 END) 
	FROM  #TmpTimeLine TT
	INNER JOIN Trip..Trip TP ON TP.tripKey = TT.tripKey 
	INNER JOIN Trip..Trip TP1 ON TP1.tripSavedKey = TP.tripSavedKey AND TP1.IsWatching=1 AND TP1.userKey=@userKey 
   	LEFT OUTER JOIN Trip..TripSaved TS ON TS.tripSavedKey = TP1.tripSavedKey	
   	
   	--Removing system generated trips and purchased trips
   	DELETE T FROM #TmpTimeLine T
   	INNER JOIN Trip..Trip TP ON T.tripKey = TP.tripKey AND (TP.isUserCreatedSavedTrip = 0 OR TP.tripStatusKey in (1,4,5,15)) 
   	
   	INSERT INTO @FollowerCount(crowdId,  FollowerCount)
	SELECT DISTINCT TL.CrowdId, COUNT(DISTINCT t.userKey) 
	FROM #TmpTimeLine TL
		INNER JOIN TripSaved TS WITH(NOLOCK) ON TL.CrowdId = TS.crowdId 
		INNER JOIN Trip T ON  T.tripSavedKey = TS.tripSavedKey 
	WHERE T.IsWatching = 1 AND TL.CrowdId is not null 
	GROUP BY TL.CrowdId
	
	UPDATE TL 
    SET TL.TripFollowerCount = fl.FollowerCount
    FROM #TmpTimeLine TL
		INNER JOIN @FollowerCount fl ON TL.CrowdId = fl.CrowdId  
		
		 	
	If @isLoggeduser = 1
	BEGIN
		SELECT * FROM 
	    (SELECT  ROW_NUMBER() OVER ( ORDER BY CASE WHEN timeLineGroupKey = 4 THEN CONVERT(DATE,createdDate,103) ELSE CreatedDate END DESC, Savings DESC) AS RowNum, * FROM #TmpTimeLine
	    ) AS RowNumbering
	    WHERE RowNum >= @limit * (@pageNumber - 1) + 1 AND RowNum <= @pageNumber * @limit
	    
	    Order BY RowNum	 
	END		 	
	
	ELSE
	BEGIN	 		 
	     
		  SELECT * FROM 
			(SELECT  ROW_NUMBER() OVER ( ORDER BY CASE WHEN timeLineGroupKey = 4 THEN CONVERT(DATE,createdDate,103) ELSE CreatedDate END DESC, Savings DESC) AS RowNum, * FROM #TmpTimeLine
			Where jsonData like Case when CHARINDEX('isFriendAlert',jsonData) > 0 Then '%"isFriendAlert": false%' else '%' end --- Added to show only selected users feeds but not their friends feeds
			) AS RowNumbering
			WHERE RowNum >= @limit * (@pageNumber - 1) + 1 AND RowNum <= @pageNumber * @limit
		    
			Order BY RowNum	 
	END
	  DROP TABLE #TmpTimeLine
END
GO
