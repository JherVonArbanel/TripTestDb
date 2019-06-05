SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 29th Sep 2014
-- Description:	Get's profit margin for TOURICO
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTouricoCommission] 
(
	@displayPrice FLOAT
	,@operatingCostPercent FLOAT
	,@operatingCostValue FLOAT	
	,@touricoNet FLOAT = 0
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @touricoCommission FLOAT = 0
			,@touricoTotalCost FLOAT = 0
			,@touricoOperatingCost FLOAT
    
    SET @touricoOperatingCost = @displayPrice * (CAST(@operatingCostPercent AS FLOAT)/100) 
											+ CAST(@operatingCostValue AS FLOAT)
    
	SET @touricoTotalCost = @touricoNet + @touricoOperatingCost
	SET @touricoCommission = @displayPrice - @touricoTotalCost        
    
	RETURN @touricoCommission

END


GO
