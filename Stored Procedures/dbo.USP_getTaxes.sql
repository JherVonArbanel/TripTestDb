SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_getTaxes]
(  
	@airResponseKey UNIQUEIDENTIFIER
)AS  
  
BEGIN  

	  SELECT * 
	  FROM TripAirResponseTax 
	  WHERE airResponseKey = @airResponseKey AND ISNULL(active, 1) = 1
 
END  

GO
