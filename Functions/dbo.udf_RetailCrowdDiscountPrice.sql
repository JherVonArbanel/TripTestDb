SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		JAYANT GURU
-- Create date: 6TH OCT 2014
-- Description:	CALCULATE'S RetailCrowdDiscountPrice
-- =============================================
CREATE FUNCTION [dbo].[udf_RetailCrowdDiscountPrice] 
(
	@crowdDiscountPercent FLOAT
	,@displayRetailPrice FLOAT
	,@touricoCalculatedBarRate FLOAT
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @retailCrowdDiscountPrice FLOAT = 0

	IF (@touricoCalculatedBarRate > 0)
	BEGIN            
		SET @retailCrowdDiscountPrice = CAST(@displayRetailPrice AS FLOAT)* (1 - CAST(@crowdDiscountPercent AS FLOAT)/ 100)
    END        
	
	RETURN @retailCrowdDiscountPrice

END
GO
