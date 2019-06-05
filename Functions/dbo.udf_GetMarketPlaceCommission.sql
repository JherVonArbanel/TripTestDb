SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 29th Sep 2014
-- Description:	Get's profit margin for EAN and Sabre
-- =============================================
create FUNCTION [dbo].[udf_GetMarketPlaceCommission] 
(
	@retailPrice FLOAT
	,@markupPercent FLOAT	
)
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @commission FLOAT = 0
    
    SET @commission = @retailPrice * (CAST(@markupPercent AS FLOAT)/100)
    
	RETURN @commission

END


GO
