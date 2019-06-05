SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author: Rohita Patel
-- Create date: 03-06-2017     
-- Description: Procedure to get image byte by trip key   
-- =============================================      
CREATE PROCEDURE [dbo].[USP_GetImageDataByTripKey]      
(      
 @TripKey as BigInt        
)       
AS      
BEGIN     

	SELECT DestinationImageData AS ImageData FROM Trip..Trip
	WHERE tripKey=@TripKey
          
END
GO
