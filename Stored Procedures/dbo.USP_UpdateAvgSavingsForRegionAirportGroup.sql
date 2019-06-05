SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateAvgSavingsForRegionAirportGroup]
	@AirportCode varchar(5),
	@AvgSaving float
	
AS
BEGIN

	UPDATE Trip..RegionAirportGroup
	set AvgSaving = @AvgSaving
	where AirportCode = @AirportCode

    
END
GO
