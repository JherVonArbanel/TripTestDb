SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================  
-- Author:  Rohita Patel
-- Create date: 24th Nov 2015  
-- Description: To update the trip privacytype
-- =============================================  
CREATE PROCEDURE [dbo].[USP_UpdateTripPrivacyType]   
 -- Add the parameters for the stored procedure here  
 @TripKey BIGINT = 0,  
 @PrivacyType INT = 1  
 
AS  
BEGIN  
 declare @tripsavedKey as uniqueidentifier; 
 SET NOCOUNT ON;   
   
   UPDATE TRIP..Trip 
   SET privacyType=@PrivacyType
   WHERE tripKey=@TripKey 
   
   Select @tripsavedKey = tripSavedKey from TRIP..Trip
   where tripKey=@TripKey 
   
   UPDATE TRIP..TripSaved 
   SET privacyType=@PrivacyType
   WHERE tripSavedKey = @tripsavedKey 

END  
  
GO
