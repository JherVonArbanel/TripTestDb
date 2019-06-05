SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE  [dbo].[InsertMinCarRate]
	@CarResponseKey NVARCHAR(50)  
AS  
BEGIN

	DECLARE @minrateTax float
    
	SELECT  @minrateTax  = (SELECT TOP 1 MIN(CD.minRateTax) 
	FROM CarResponse CR WITH(NOLOCK)
		INNER JOIN carresponsedetail CD WITH(NOLOCK) ON CR.carResponseKey = CD.carResponseKey 
			AND CR.carVendorKey = CD.carVendorKey AND CD.carResponseKey = @CarResponseKey) 
    
	Update CR 
	SET		minRateTax		= @minrateTax,
			minrate			= CD.minrate,
			carCategoryCode = CD.carCategoryCode,
			RateQualifier	= CD.RateQualifier,
			ReferenceId		= CD.ReferenceId,
			ReferenceType	= CD.ReferenceType,
			ReferenceDateTime = CD.ReferenceDateTime
	FROM CarResponse CR WITH(NOLOCK)
		INNER JOIN carresponsedetail CD WITH(NOLOCK)  ON CR.carResponseKey = CD.carResponseKey AND CR.carVendorKey = CD.carVendorKey 
			AND CD.carResponseKey = @CarResponseKey AND CD.minRateTax = @minrateTax 
	WHERE CR.carResponseKey = @CarResponseKey 
     
   --Update CarResponse   
   --SET carCategoryCode  =( SELECT TOP 1  CD.carCategoryCode   
   --    From CarResponse CR Inner join carresponsedetail CD  ON CR.carResponseKey = CD.carResponseKey   
   --    And CR.carVendorKey = CD.carVendorKey   and CD.carResponseKey = @CarResponseKey  
   --    and CR.minRate = CD.minRate    
   -- )  
   --Where carResponseKey = @CarResponseKey  
   
   --Update CarResponse   
   --SET RateQualifier = ( SELECT TOP 1  CD.RateQualifier
   --    From CarResponse CR Inner join carresponsedetail CD  ON CR.carResponseKey = CD.carResponseKey   
   --    And CR.carVendorKey = CD.carVendorKey   and CD.carResponseKey = @CarResponseKey  
   --    and CR.minRate = CD.minRate    
   -- )  
   --Where carResponseKey = @CarResponseKey  
   
   --Update CarResponse   
   --SET ReferenceId = ( SELECT TOP 1  CD.ReferenceId
   --    From CarResponse CR Inner join carresponsedetail CD  ON CR.carResponseKey = CD.carResponseKey   
   --    And CR.carVendorKey = CD.carVendorKey   and CD.carResponseKey = @CarResponseKey  
   --    and CR.minRate = CD.minRate    
   -- )  
   --Where carResponseKey = @CarResponseKey  
   
   --Update CarResponse   
   --SET ReferenceType = ( SELECT TOP 1  CD.ReferenceType
   --    From CarResponse CR Inner join carresponsedetail CD  ON CR.carResponseKey = CD.carResponseKey   
   --    And CR.carVendorKey = CD.carVendorKey   and CD.carResponseKey = @CarResponseKey  
   --    and CR.minRate = CD.minRate    
   -- )  
   --Where carResponseKey = @CarResponseKey  
   
   --Update CarResponse   
   --SET ReferenceDateTime = ( SELECT TOP 1  CD.ReferenceDateTime
   --    From CarResponse CR Inner join carresponsedetail CD  ON CR.carResponseKey = CD.carResponseKey   
   --    And CR.carVendorKey = CD.carVendorKey   and CD.carResponseKey = @CarResponseKey  
   --    and CR.minRate = CD.minRate    
   -- )  
   --Where carResponseKey = @CarResponseKey  
END

GO
