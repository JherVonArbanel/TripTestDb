SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetAirResponses]  
(  
	@airresponsekey UNIQUEIDENTIFIER, 
	@airLegnumber INT, 
	@gdsSourceKey INT
)  
AS  
BEGIN  
  
	SELECT * FROM [udf_GetAirResponses](@airresponsekey, @airLegnumber, @gdsSourceKey )  
  
END  
GO
