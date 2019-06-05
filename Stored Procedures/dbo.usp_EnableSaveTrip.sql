SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
   
CREATE PROCEDURE [dbo].[usp_EnableSaveTrip] (@tripId int , @isEnable bit )    
AS  
BEGIN   
    
 Update Trip Set IsWatching = @isEnable where tripKey = @tripId  
 

END
GO
