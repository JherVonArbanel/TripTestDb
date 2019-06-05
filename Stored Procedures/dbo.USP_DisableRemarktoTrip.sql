SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_DisableRemarktoTrip]  
(    
	@Active BIT,
	@TripKey INT,
	@GeneratedType SMALLINT
)
AS 
    
BEGIN    
  
	UPDATE TripPNRRemarks 
	SET Active = @Active 
	WHERE TripKey = @TripKey AND GeneratedType = @GeneratedType

END    
  
GO
