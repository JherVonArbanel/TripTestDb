SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateCrossReferenceTrip] 
(      
 @tripID INT,
 @crossReferenceTripId INT
)      
AS    
BEGIN    
   UPDATE TRIP
   SET cross_reference_trip_id = @crossReferenceTripId
   WHERE tripKey = @tripID
END
GO
