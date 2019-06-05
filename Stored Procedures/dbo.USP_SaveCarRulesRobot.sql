SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 28th Dec 2012
-- Description:	To save the car rules in TripCarResponse
-- =============================================
CREATE PROCEDURE [dbo].[USP_SaveCarRulesRobot] 
	@CarResponseDetailKey Uniqueidentifier
	,@CarRule Varchar(2000)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	/*In nightly robot the carResponseDetailKey is stored in carResponseKey column from stored procedure [USP_GetTripSavedDealCarMinPrice]*/
    Update TripCarResponse Set carRules = @CarRule Where carResponseKey = @CarResponseDetailKey
	
END
GO
