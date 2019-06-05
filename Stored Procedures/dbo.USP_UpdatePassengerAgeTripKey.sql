SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 1st Feb 2013
-- Description:	Update PassengerAge Table with Tripkey based on TripRequestKey
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdatePassengerAgeTripKey]
	-- Add the parameters for the stored procedure here
	@tripRequestKey INT
	,@tripKey INT
AS
BEGIN
	
	SET NOCOUNT ON;
	
	UPDATE PassengerAge SET TripKey = @tripKey WHERE TripRequestKey = @tripRequestKey
    
END
GO
