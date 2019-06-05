SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 10th August 2017
-- Description:	Converted Inline Query to SP
-- =============================================

CREATE PROCEDURE [dbo].[USP_InsertAirTripRule]
	@airSegmentKey UNIQUEIDENTIFIER, 
	@airFareBasisCode VARCHAR(50), 
	@airTripRulesContent VARCHAR(50)
AS
BEGIN

	SET NOCOUNT ON;

	INSERT INTO AirTripRule (
		airSegmentKey, airFareBasisCode, airTripRulesContent)
	VALUES (
		@airSegmentKey , @airFareBasisCode,   @airTripRulesContent)

END
GO
