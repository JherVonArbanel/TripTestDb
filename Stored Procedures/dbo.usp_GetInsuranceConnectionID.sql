SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Milind Lad  
-- Create date: 9/11/2012 14:57PM  
-- Description: Get connection info for insurance operation set in siteConfiguration.   
-- =============================================  
CREATE PROCEDURE [dbo].[usp_GetInsuranceConnectionID]  
 -- Add the parameters for the stored procedure here  
 @ConnectionID int  
AS  
BEGIN  
   
 SET NOCOUNT ON;  
  
 SELECT * FROM InsuranceConnection WHERE connectionID = @ConnectionID  
END
GO
