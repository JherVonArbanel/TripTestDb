SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Pradee Gupta>  
-- Create date: <2-Feb-16>  
-- Description: <This will be used to bring, count of hashtag stored and will be used to display on hotel landing page as per new requirement #15646>  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_PopularDiscoveHashTags]  
  
AS  
BEGIN  
  
--SELECT TOP 1 '1' AS [Count] ,'#3Star' as [HashTag] FROM Trip..TripHashTagMapping  
--UNION ALL  
--SELECT TOP 1  '2' AS [Count] ,'#4Star' as [HashTag] FROM Trip..TripHashTagMapping  
--UNION ALL  
--SELECT TOP 1  '3' AS [Count] ,'#5Star' as [HashTag] FROM Trip..TripHashTagMapping  
--UNION ALL  
--SELECT TOP 1  '4' AS [Count] ,'#Package' as [HashTag] FROM Trip..TripHashTagMapping  
--UNION ALL  
  
--SELECT * FROM   
--(  
  
SELECT COUNT(THM.HashTag) AS [Count],THM.HashTag from Trip..TripHashTagMapping THM
inner join  Trip..Trip T on T.tripKey = THM.TripKey and T.tripStatusKey not in (5,6,17) and T.privacyType=1
GROUP BY THM.HashTag  
--HAVING COUNT(THM.HashTag)>0 and THM.HashTag NOT IN ('#air','#car','#hotel','#package')  
HAVING COUNT(THM.HashTag)>0 
ORDER BY COUNT(THM.HashTag) desc  
--) T  

END
GO
