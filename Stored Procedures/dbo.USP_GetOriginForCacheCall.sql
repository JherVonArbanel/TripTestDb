SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Ashima Gupta 
-- Create date: 10 May 2016 
-- Description: Get data to Call Destination Finder  
-- =============================================  
--exec [USP_TripSavedDealAirSearchRequestData] 2, 5, 2
CREATE PROCEDURE [dbo].[USP_GetOriginForCacheCall]  
 -- Add the parameters for the stored procedure here  
	--@SiteKey int  
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON; 
 SELECT DISTINCT(Origin) from DestinationFinderData 
 END
GO
