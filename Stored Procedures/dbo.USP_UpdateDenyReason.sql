SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateDenyReason]  
(    
	@deniedReason VARCHAR(500),
	@TripKey INT
)
AS 
    
BEGIN    
  
	UPDATE Trip SET deniedReason = @deniedReason, tripStatusKey = 9 WHERE tripKey = @TripKey

END    
  
GO
