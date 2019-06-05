SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 1st Oct 2014
-- Description:	Calculate Tourico cost basis for crowd price
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTouricoCostBasisForCrowd] 
(
	@touricoNet FLOAT	
	,@touricoFloorMarginPercent FLOAT
	,@operatingCostPercent FLOAT
	,@operatingCostValue FLOAT	
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @touricoCostBasisForCrowd FLOAT = 0
    
	SET @touricoCostBasisForCrowd = CAST(@touricoNet AS FLOAT) / (1 - CAST(@touricoFloorMarginPercent AS FLOAT)/100);
    SET @touricoCostBasisForCrowd = CAST(@touricoCostBasisForCrowd AS FLOAT)/ (1 - CAST(@operatingCostPercent AS FLOAT)/100) + CAST(@operatingCostValue AS FLOAT)
    
	RETURN @touricoCostBasisForCrowd

END


GO
