SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================      
-- Author:  Priyanka Deshmukh      
-- Create date: 23/11/2011      
-- Description: Get Meeting Code for Event Code List      
-- =============================================      
CREATE PROCEDURE [dbo].[USP_GetEventCodeList]      
@siteKey int
AS         
BEGIN      
      
 SELECT meetingCode FROM (      
  SELECT DISTINCT ME.meetingCode       
    FROM vault.dbo.Meeting ME       
   WHERE Status ='Confirmed' AND siteKey = @siteKey  --IsDisplay = 1   
  -- UNION       
  --SELECT DISTINCT TR.meetingCodeKey AS meetingCode       
  --  FROM Trip.dbo.Trip TR       
  -- WHERE TR.userKey = 0 AND TR.meetingCodeKey IS NOT NULL AND TR.meetingCodeKey <> ''      
) AS MeetCode      
       
END  
GO
