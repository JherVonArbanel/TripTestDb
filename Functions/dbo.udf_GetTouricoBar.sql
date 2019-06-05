SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 1st Oct 2014
-- Description:	Get's Tourico bar price using the markup percent
-- =============================================
CREATE FUNCTION [dbo].[udf_GetTouricoBar] 
(
	@markupPercent FLOAT
	,@touricoNetrate FLOAT	
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @touricoBar FLOAT = 0
    
    SET @touricoBar = CAST(@touricoNetrate AS FLOAT) / (1 - (CAST(@markupPercent AS FLOAT) / 100))        
    
	RETURN @touricoBar

END
GO
