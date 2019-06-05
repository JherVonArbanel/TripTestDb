SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_IsTripExistByPNR]
(  
	@recordLocator VARCHAR(50)
)AS  
  
BEGIN  

	SELECT tripKey FROM Trip WHERE recordLocator = @recordLocator
 
END  

GO
