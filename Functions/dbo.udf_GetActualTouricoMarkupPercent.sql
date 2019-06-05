SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 30th Sep 2014
-- Description:	Get's profit percent for TOURICO
-- =============================================
CREATE FUNCTION [dbo].[udf_GetActualTouricoMarkupPercent] 
(	
	@touricoMinimumNet FLOAT
	,@sellingPrice FLOAT	
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @markupPercent FLOAT
    
    SET @markupPercent = (CAST(@sellingPrice AS FLOAT) - CAST(@touricoMinimumNet AS FLOAT))/CAST(@touricoMinimumNet AS FLOAT) * 100
    
	RETURN @markupPercent

END


GO
