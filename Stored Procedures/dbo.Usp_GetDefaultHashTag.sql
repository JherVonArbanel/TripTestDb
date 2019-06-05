SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  <Pradeep Gupta>  
-- Create date: <14-jun-16>  
-- Description: <getting default Hashtag as per new requirement>  
-- =============================================  
CREATE PROCEDURE [dbo].[Usp_GetDefaultHashTag]  
AS  
BEGIN  
   
    select HashTag as [HashTag] , CategoryKey from HashTag 
END
GO
