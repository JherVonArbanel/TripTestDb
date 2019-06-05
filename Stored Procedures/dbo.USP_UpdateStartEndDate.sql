SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateStartEndDate]  
( 
@StartDate DateTime,
@EndDate DateTime,
@tripkey int	
)
AS  
BEGIN
	Update Trip set startDate = @StartDate , endDate = @EndDate 
	WHERE tripKey = @tripkey
END

GO
