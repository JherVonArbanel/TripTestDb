SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Milind Lad  
-- Create date: 12/12/2017 14:57PM  
-- Description: Get connection info for CHUB operation set in siteConfiguration.   
-- =============================================  
create PROCEDURE [dbo].[usp_GetCHUBConnectionID]  
 -- Add the parameters for the stored procedure here  
 @ConnectionID int  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 SELECT * FROM Trip..CHUBConnection WHERE connectionID = @ConnectionID  
END  
GO
