SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConnectionInfo1]  
as   
 
  BEGIN  
  SELECT [ConnectionID]  
     ,[UserName]  
     ,[Password]  
     ,[URL]  
     ,[IPCC]  
     ,[Domain]  
     ,[FromPartyID]  
     ,[ToPartyID]  
     ,[MessageID]  
     ,[MinimumSession]  
     ,[MaximumSession]  
     ,[DefaultSessionTimeOut]  
     ,[ActulSessionTimeOut]  
     ,[DefaultConnection]  
    FROM [SabreConnection]  
    Where [DefaultConnection] =1   
   End
GO
