SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  Manoj Naik    
-- Create date: 11/05/2018 19:57Hrs
-- Description: Get connection info for AAPartner operation set in siteConfiguration.     
-- =============================================    
CREATE PROCEDURE [dbo].[usp_GetAAPartnerConnectionID]    
 -- Add the parameters for the stored procedure here    
 @ConnectionID int    
AS    
BEGIN    
     
 SET NOCOUNT ON;    
    
 SELECT * FROM Trip..AAPartnerConnection WHERE connectionID = @ConnectionID    
END 

GO
