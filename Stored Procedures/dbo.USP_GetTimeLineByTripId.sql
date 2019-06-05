SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
-- =============================================  
-- Author:  Manoj Kumar Naik  
-- Create date: 19-01-2016  
-- Description: GetTimeLineByTripId  
-- =============================================  
-- EXEC USP_GetTimeLineByTripId '34910,34941,35038',561945
CREATE PROCEDURE [dbo].[USP_GetTimeLineByTripId]  
--DECLARE  
  @tripKey nvarchar(MAX),  
  @userKey bigint = 0
AS  
BEGIN  

--SELECT @tripKey=N'25471,25787,29052,26132,27089,27337,28142,28163,28208,28542,28708,29216,29411,29416,29545,29782,29783,29868,30124,30126,30127,30128,30130,30133,30134,30136,30206,30190,30238,30278,30457,30459,30482,30483,30484,30516,30726,30783,30784,30811,30812,30832,30833,30834'
--	,@userKey=1257
  
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
	CREATE TABLE #tripKey(tripKey INT)  
	CREATE TABLE #TimeLine(ID INT, userKey INT, TimeLineGroupKey INT, tripKey INT, savings Float, TimeLineKey INT)  
  
	INSERT INTO #tripKey 
	select * from ufn_CSVSplitStringtoInt(@tripKey)
	
	INSERT INTO #TimeLine 
	SELECT ROW_NUMBER() OVER (PARTITION BY TM.userKey,TM.timeLineGroupKey,TM.tripKey ORDER BY TM.createdDate DESC) AS ID,userKey
	,TM.timeLineGroupKey,TM.tripKey, savings,timeLineKey
	FROM [Trip].[dbo].[TimeLine] TM
		INNER JOIN #tripKey tk ON TM.tripKey = tk.tripKey 
	WHERE TM.timeLineGroupKey=4 --and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) 
	and TM.userKey =@userKey  and TM.showAlert =1 and TM.savings > 0 

	DELETE #TimeLine WHERE ID > 1

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName)
		SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,0,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName
		FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		where timeLineGroupKey=1 and  tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) and T.userKey =@userKey ORDER BY createdDate DESC
--SELECT '1', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount,DestinationCode)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName   as UserName, TL.LikeCount, CM.CommentsCount,TD.tripTo
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		 INNER JOIN TRIP..TripDetails TD ON T.tripKey=TD.tripKey
		 LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0 
            		 
		  where timeLineGroupKey=2 and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) and T.userKey =@userKey ORDER BY createdDate DESC
--SELECT '2', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName,LikeCount,CommentsCount,DestinationCode)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings ,U.userFirstName   as UserName,LikeCount,CommentsCount,TD.tripTo
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
		  INNER JOIN TRIP..TripDetails TD ON T.tripKey=TD.tripKey
	   LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0      
		 where timeLineGroupKey=3 and T.tripKey > 0 and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) and T.userKey =@userKey ORDER BY createdDate DESC
--SELECT '3', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName, LikeCount, CommentsCount,DestinationCode)
	  --SELECT timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings 
		 --FROM Trip..TimeLine where timeLineGroupKey=4 and userKey=@UserKeys and showAlert =1 and savings > 0 ORDER BY createdDate DESC
		SELECT  T.timeLineKey,T.userKey,T.timeLineGroupKey,T.jsonData,T.isRead,T.tripKey,T.createdDate,null,T.savings
			,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName, TL.LikeCount, CM.CommentsCount,TD.tripTo
		FROM Trip..TimeLine T
			INNER JOIN #TimeLine TM ON T.timeLineKey = TM.TimeLineKey 
			INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey 
			 INNER JOIN TRIP..TripDetails TD ON T.tripKey=TD.tripKey
		 	LEFT OUTER JOIN 
		 	(
		 		Select tripKey, COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey
			) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
			LEFT OUTER JOIN 
			(
				Select tripKey, COUNT(1) CommentsCount from Trip..Comments Group By tripKey
			) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0      
		--where timeLineKey in(		 		 
		-- Select timeLineKey FROM
		-- (
		--			SELECT ROW_NUMBER() OVER (PARTITION BY userKey,timeLineGroupKey,tripKey ORDER BY createdDate DESC) AS ID,userKey
		--				,timeLineGroupKey,TM.tripKey, savings,timeLineKey
		--			FROM [Trip].[dbo].[TimeLine] TM
		--							INNER JOIN #tripKey tk ON TM.tripKey = tk.tripKey 
		--			WHERE timeLineGroupKey=4 --and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) 
		--				and T.userKey =@userKey  and showAlert =1 and savings > 0 
		--) TM WHERE TM.ID<2 					
		--			)			
	ORDER BY createdDate DESC 

--SELECT '4', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount,DestinationCode)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
		   (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
		  ,savings,U.userFirstName   as UserName , TL.LikeCount, CM.CommentsCount,TD.tripTo 	   
		FROM Trip..TimeLine T INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
			INNER JOIN #tripKey tk ON T.tripKey = tk.tripKey 
			 INNER JOIN TRIP..TripDetails TD ON T.tripKey=TD.tripKey
			LEFT OUTER JOIN 
			(
				Select tripKey , COUNT(1) AS LikeCount 
				from Trip..TripLike 
				Group By tripKey
			) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
			LEFT OUTER JOIN 
			(
				Select tripKey, COUNT(1) CommentsCount from Trip..Comments Group By tripKey
			) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0 
		 WHERE timeLineGroupKey=5 --and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) 
			and T.userKey =@userKey 
		 ORDER BY createdDate DESC
	  
--SELECT '5', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData ,savings,UserName)
	  SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,0 ,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName 
	  FROM Trip..TimeLine T
	  INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		WHERE timeLineGroupKey=6 and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) and T.userKey =@userKey ORDER BY createdDate DESC
		 
--SELECT '6', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName,LikeCount,CommentsCount,DestinationCode)
	  SELECT timeLineKey,t.userKey,timeLineGroupKey,jsonData,isRead,T.tripKey,T.createdDate,
	  (Select TOP 1 jsonData FROM Trip..TimeLine TP where TP.timeLineGroupKey=4 AND TP.tripKey = T.tripKey Order By createdDate DESC) jsonData_TP 
	  ,savings,U.userFirstName + ' ' + Substring(U.userLastName,1,1)  as UserName,LikeCount,CommentsCount,TD.tripTo
		 FROM Trip..TimeLine T 
		 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
		  INNER JOIN TRIP..TripDetails TD ON T.tripKey=TD.tripKey
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) AS LikeCount from Trip..TripLike Group By tripKey) TL ON TL.tripKey = T.tripKey AND TL.tripKey > 0
		LEFT OUTER JOIN (Select tripKey 
      , COUNT(1) CommentsCount from Trip..Comments Group By tripKey) CM ON CM.tripKey = T.tripKey AND CM.tripKey > 0      
		 WHERE timeLineGroupKey=7 and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) and T.userKey =@userKey ORDER BY createdDate DESC
		 
--SELECT '7', GETDATE()

	  INSERT INTO #TmpTimeLine (timeLineKey,userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,associatedJSONData,savings,UserName, LoggedInUserKey)
	  SELECT timeLineKey,T.userKey,timeLineGroupKey,jsonData,isRead,tripKey,createdDate,null,savings , U.userFirstName  as userName, @userKey
	 FROM Trip..TimeLine T 
	 INNER JOIN Vault.dbo.[User] U ON U.userKey = T.userKey
	 where timeLineGroupKey=8 and  T.tripKey in (select * from ufn_CSVSplitStringtoInt(@tripKey)) and T.userKey =@userKey ORDER BY createdDate DESC
	
	 update TT set TT.isExpired = 1 FROM #TmpTimeLine TT 
   	INNER JOIN Trip..Trip TP ON TP.tripKey = TT.tripKey
   	 WHERE TP.startDate < GETDATE()
   	 
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
	
--SELECT '8', GETDATE()
        
   --SELECT * 
   --FROM   
   --(
		SELECT  ROW_NUMBER() OVER ( ORDER BY CreatedDate DESC, Savings DESC) AS RowNum, * 
		FROM #TmpTimeLine
	--) AS RowNumbering  
 --    Order BY RowNum  
--SELECT '9', GETDATE()
     
   DROP TABLE #TmpTimeLine  
   DROP TABLE #tripKey 
   DROP TABLE #TimeLine  
    
END  
GO
