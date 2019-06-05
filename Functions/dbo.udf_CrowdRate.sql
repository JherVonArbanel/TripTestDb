SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 23rd Sep 2014
-- Description:	Returns crowd rate for marketplace
-- =============================================
CREATE FUNCTION [dbo].[udf_CrowdRate]
(
	@displayRetailPrice FLOAT
	,@touricoCostBasisCrowdRate FLOAT
	,@retailCrowdDiscountPrice FLOAT
	,@isCrowdRate BIT = 0
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @crowdRate FLOAT = 0;
	
    IF(@touricoCostBasisCrowdRate < @displayRetailPrice)
    BEGIN		
		SET @crowdRate = (SELECT MAX(Price) FROM 
						 (VALUES (CAST(@touricoCostBasisCrowdRate AS FLOAT)),(CAST(@retailCrowdDiscountPrice AS FLOAT))) 
						 AS AllPrices(Price))
    END
    ELSE IF (@isCrowdRate = 0)
    BEGIN
		SET @crowdRate = @displayRetailPrice
    END
	
	RETURN @crowdRate

END

GO
