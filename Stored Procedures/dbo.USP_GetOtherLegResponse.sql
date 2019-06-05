SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetOtherLegResponse]
(  
	@airresponsekey UNIQUEIDENTIFIER, 
	@airLegnumber	INT, 
	@airline		VARCHAR(100), 
	@gdsSourceKey	INT
)AS  
  
BEGIN  

	SELECT * FROM [udf_GetAirResponsesBasedOnAirline](@airresponsekey, @airLegnumber, @airline, @gdsSourceKey) 

END  

GO
