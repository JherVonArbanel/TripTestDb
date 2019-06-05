SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetAirResponseOnGUID]  
(    
	@airResponseKey UNIQUEIDENTIFIER
)
AS 
    
BEGIN    
  
	Select * from TripAirResponse where airResponseKey=@airResponseKey

END    
  
GO
