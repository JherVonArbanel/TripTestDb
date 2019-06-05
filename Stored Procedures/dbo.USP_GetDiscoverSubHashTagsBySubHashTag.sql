SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  <Author,,Name>    
-- Create date: <Create Date,,>    
-- Description: <Description,,>    
-- =============================================    
--USP_GetDiscoverSubHashTagsBySubHashTag 562416,5,'#SanFrancisco,#mar2016' 
--USP_GetDiscoverSubHashTagsBySubHashTag 562416,5,'#Miami,#air,#hotel','27857,26319,26318,26873,26871,25211,26844,26720,26424,26423,27870,26178,27470,27468,22836,27861,25317,25835,28007,27860'
Create PROCEDURE [dbo].[USP_GetDiscoverSubHashTagsBySubHashTag]     
 @UserKey int,    
 @SiteKey int,    
 @HashTag nvarchar(400),
 @TripKey nvarchar(400)
AS    
BEGIN    
     
 SET NOCOUNT ON;    
 
 set @HashTag = ''''+@HashTag +''''
 set @HashTag = REPLACE(@HashTag,',',''',''')

declare @finalQuery varchar(max)  
set @finalQuery = 'select distinct HashTag, ''1'' as [Value] from trip..TripHashTagMapping where TripKey in ('+@TripKey+') and HashTag NOT IN ('+@HashTag+')'  
 -- print @finalQuery 
 exec(@finalQuery)
 
       
END 
GO
