SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  Rajkumar Tatipaka    
-- Create date: 28-Apr-2016    
-- Description: Get @users details for notifications    
-- =============================================    
--EXEC dbo.USP_GetNotificationUserTags 561945,''    
CREATE PROCEDURE [dbo].[USP_GetNotificationUserTags]     
 @UserKey int,  
 @atUserKeys varchar(max) = null    
AS    
BEGIN    
 SET NOCOUNT ON;    
 Declare @userTagCount Int = 0  
 --*********** Insert @ userkeys in temp***********  
 Declare @UserKeys table  
 (UserKey int)  
   
 Declare @isLoggeduser bit = 0  
   
 INSERT INTO @UserKeys  
 (UserKey)  
 SELECT * From dbo.ufn_DelimiterToTable(@atUserKeys,',')  
  
 If Not Exists(Select * from @UserKeys)  
 BEGIN  
  SET @isLoggeduser = 1  
   
  INSERT INTO @UserKeys  
  (UserKey)    
  SELECT @userKey  
 END  
   
 CREATE TABLE #TmpUserTags  
 (    
    [userKey] [bigint] NOT NULL,    
       [username] [nvarchar](200) NULL,  
       [recencyRanking] FLOAT DEFAULT(0)  
 )   
   
 CREATE TABLE #TmpRecentActivity  
 (    
    [userKey] [bigint] NOT NULL,    
       [username] [nvarchar](200) NULL,  
       [recency] FLOAT DEFAULT(0),              
    [recencyRanking] FLOAT DEFAULT(0)  
 )   
   
  --Following Details    
  insert into #TmpUserTags (userKey,username)  
  SELECT i.userid as [userkey] , LOWER(U.userFirstName + Left(U.userLastName,1)) as [username] --,0 as IsFollowers      
  FROM Loyalty.dbo.UserFollowers i        
  INNER JOIN vault..[User] U on i.userid = U.userKey        
  --Left Join loyalty.dbo.UserMap UM on i.UserId =UM.UserId        
  WHERE i.FollowerId in (Select userKey From @UserKeys) and @isLoggeduser = 1      
  UNION         
  --Followers details        
  SELECT FollowerId as [userkey], LOWER(U.userFirstName+ Left(U.userLastName,1)) as [username] --,1 as IsFollowers        
  FROM Loyalty.dbo.UserFollowers i        
  INNER JOIN vault..[User] U on i.FollowerId = U.userKey        
  --Left Join loyalty.dbo.UserMap UM on i.FollowerId =UM.UserId        
  WHERE i.userId in (Select userKey From @UserKeys) and @isLoggeduser = 1    
  UNION     
  SELECT  dbo.Trip.userKey as [userkey],LOWER(U.userFirstName+ Left(U.userLastName,1))   as [username]   
  FROM    dbo.Trip INNER JOIN    
                dbo.TripSaved ON dbo.Trip.tripSavedKey = dbo.TripSaved.tripSavedKey    
                INNER JOIN Vault.dbo.[User] U on dbo.Trip.userKey = U.userKey    
  WHERE dbo.Trip.tripKey IN (SELECT tripKey FROM Trip..TimeLine T WHERE userKey in (Select userKey From @UserKeys))     
  AND  IsWatching = 1    
    
  SELECT @userTagCount = COUNT(*) FROM #TmpUserTags  
    
  -- commented following things as per userstory 18107  
  IF(@userTagCount =0 AND @isLoggeduser = 1 ANd 1=2)  
  BEGIN  
 -- insert user who have done recent acitivity  
 INSERT INTO #TmpRecentActivity (userKey , username , recency)  
 SELECT TL.userKey,LOWER(U.userFirstName + Left(U.userLastName,1)), DATEDIFF(day,TL.CreatedDate,GETDATE()) as Recency    
 FROM TimeLine TL INNER JOIN vault..[User] U on TL.userKey = U.userKey  
 WHERE TL.CreatedDate > = DATEADD(MONTH, -3, GETDATE()) AND TL.timeLineGroupKey <> 4;   
   
 -- insert user who have created trip recently  
 INSERT INTO #TmpRecentActivity (userKey , username , recency)  
 SELECT T.userKey , LOWER(U.userFirstName + Left(U.userLastName,1)), DATEDIFF(day,T.CreatedDate,GETDATE()) as Recency        
 FROM Trip T INNER JOIN vault..[User] U on T.userKey = U.userKey  
 where T.siteKey =5 AND T.IsWatching = 1 AND T.CreatedDate > = DATEADD(MONTH, -3, GETDATE());  
   
 UPDATE #TmpRecentActivity              
   SET recencyRanking =              
   CASE              
    WHEN recency = 0 THEN 5              
    WHEN recency = 1 THEN 4.5              
    WHEN recency = 7 THEN 4              
    WHEN recency BETWEEN 8 AND 14 THEN 3              
    WHEN recency BETWEEN 13 AND 21 THEN 2              
    WHEN recency BETWEEN 20 AND 90 THEN 1.5                  
    ELSE 0              
   END    
 -- SELECT * FROM #TmpRecentActivity WHERE  recencyRanking >0 ORDER BY recencyRanking DESC;  
 INSERT INTO #TmpUserTags (userKey,username ,recencyRanking)  
 SELECT userKey, MAX(username), MAX(recencyRanking)  from #TmpRecentActivity GROUP BY  userKey  
   
  END  
    
  --this will add logged in user, if logged in user is not in above list.
  IF Not Exists(Select userKey from #TmpUserTags where userKey = @UserKey) 
  BEGIN
  INSERT INTO #TmpUserTags (userKey,username) 
  SELECT @UserKey AS [userkey], LOWER(U.userFirstName+ Left(U.userLastName,1))   AS [username]  FROM Vault.dbo.[User] U 
  WHERE u.userKey = @UserKey
  END
  
  --this will remove logged in user, if logged in user is present in list so that hashtag for logged in user will not create
  --DELETE FROM #TmpUserTags WHERE userKey = @UserKey
  
  SELECT * FROM #TmpUserTags ORDER BY recencyRanking DESC   
    
END
GO
