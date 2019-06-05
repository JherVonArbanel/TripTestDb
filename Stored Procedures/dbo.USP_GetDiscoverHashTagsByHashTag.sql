SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetDiscoverHashTagsByHashTag] 
	@UserKey int,
	@SiteKey int,
	@HashTag nvarchar(1000),
	@TrendingPeople int = 0,
	@IsCrowdEvent bit = 0 --Show only events crowds in discover
AS
BEGIN
	
	SET NOCOUNT ON;
	
		If Isnull(@HashTag,'') = ''
			BEGIN
				EXEC USP_PopularDiscoveHashTags
			END
		ELSE
		BEGIN
   --************* Get HashTags to show on search
		DECLARE @HashTags TABLE                
		(HashTag varchar(200))    
  
     
		Insert Into @HashTags (HashTag)                
		Select String
		From dbo.ufn_DelimiterToTable(rtrim(ltrim(@HashTag)),',')     
		
		--**************** Get trips by hashtags *********************
		--Select * from @HashTags
		
		DECLARE @HashTagTrips TABLE (HashTag varchar(400), tripKey INT) 

		DECLARE @HName VARCHAR(400)

		
		INSERT INTO @HashTagTrips 
		SELECT HashTag, TripKey From TripHashTagMapping WITH(NOLOCK) WHERE (HashTag = (SELECT TOP 1 HashTag FROM @HashTags))

		DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR  SELECT HashTag FROM @HashTags 


		OPEN db_cursor 
			FETCH NEXT FROM db_cursor INTO @HName 

			WHILE @@FETCH_STATUS = 0 
			BEGIN 

				   PRINT @HName 
				   DELETE FROM @HashTagTrips WHERE TripKey NOT IN (SELECT TripKey FROM TripHashTagMapping WITH(NOLOCK) 
				   WHERE HashTag = @HName or HashTag = REPLACE(@HName,' ','') ) 

			FETCH NEXT FROM db_cursor INTO @HName 
			END 

		CLOSE db_cursor 
		DEALLOCATE db_cursor 
		
		SELECT  HashTag
		From TripHashTagMapping c 
		Where TripKey IN (	Select a.Tripkey FROM TripDetails a WITH (NOLOCK)
							INNER JOIN TripHashTagMapping  b WITH (NOLOCK) on a.tripKey = b.TripKey
							INNER JOIN Trip T1 WITH (NOLOCK) ON a.tripKey = T1.tripKey   
							WHERE 
							--b.HashTag = Case when Isnull(@HashTag,'') = '' then b.HashTag else @HashTag End
							1 =	CASE WHEN @HashTag = '' THEN 1 ELSE  
							(
								SELECT top 1 1 FROM @HashTagTrips TH WHERE a.tripKey = TH.TripKey 
							)End 
							And T1.tripStatusKey  not in (5,6,17) --<> 17
							And T1.privacyType = 1  		  		  
							AND T1.IsWatching = 1
							--AND T1.userKey = Case When @TrendingPeople > 0 Then @TrendingPeople else T1.userKey End --as per new req. trending people and crowd events removed , so commented to remove unnecessary checks
							AND a.tripStartDate > DATEADD(D,2, GetDate()))
							AND c.HashTag Not in (Select HashTag From @HashTags)
							--AND 1 = Case When @IsCrowdEvent = 1
							--		Then (Select top 1 1 From AttendeeTravelDetails ATD 
							--				INNER JOIN  EventAttendees ON  EventAttendees.eventAttendeeKey = ATD.eventAttendeekey
							--				Where EventAttendees.userKey = @UserKey And ATD.attendeeTripKey = c.TripKey ) 
							--		Else 1 end --as per new req. trending people and crowd events removed , so commented to remove unnecessary checks
		GROUP By HashTag					
		ORDER BY	CASE WHEN HashTag = '#air' Then 3 ELSE 
					CASE When HashTag = '#hotel'  THEN 2 ELSE 
					CASE When HashTag = '#car' THEN 1 ELSE
					CASE When HashTag = '#package' THEN 0
					END END END END desc,HashTag					
		END						
			
END
GO
