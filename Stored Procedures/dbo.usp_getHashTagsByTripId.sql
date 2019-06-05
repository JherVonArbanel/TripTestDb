SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author: Keyur Sheth    
-- Create date: 18 February 2015    
-- Description: This procedure returns hasht tags associated with a trip by trip id    
-- =============================================    
CREATE PROCEDURE [dbo].[usp_getHashTagsByTripId]    
 @tripId INT     
AS    
BEGIN    
 SELECT REPLACE(HashTag,'#','') as HashTag FROM Trip..TripHashTagMapping WHERE TripKey = @tripId    
 ----//TFS #18878 replace #
END
GO
