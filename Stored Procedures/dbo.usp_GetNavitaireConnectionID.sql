SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================  
-- Author:  Milind Lad  
-- Create date: 12/12/2017 14:57PM  
-- Description: Get connection info for CHUB operation set in siteConfiguration.   
-- =============================================  
CREATE PROCEDURE [dbo].[usp_GetNavitaireConnectionID]  
 -- Add the parameters for the stored procedure here  
 @ConnectionID int  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 SELECT * FROM Trip..NavitaireConnection WHERE connectionID = @ConnectionID  
END
GO
