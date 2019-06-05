SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 29th Sep 2014
-- Description:	Get's profit margin for TOURICO
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTouricoMarkupValue] 
(
	@touricoNet FLOAT	
	,@markupPercent FLOAT	
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @touricoTotalCost FLOAT = 0
    
    SET @touricoTotalCost = @touricoNet * (1 + @markupPercent/100)
    
	RETURN @touricoTotalCost

END


GO
