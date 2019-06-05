SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		ANUPAM
-- Create date: 06/Dec/2013
-- Description:	Get Pending Points, Bonus Points, Travel Points
-- Exec USP_GetPointsForUserTrip 12285,560812
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetPointsForUserTrip]
	@tripKey INT,
	@userKey INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 /* Get Points Details */
 ----------------------------------------------------------------
 Declare @iPendingPoints INT
 Declare @iBonusPoints INT
 Declare @iTravelPoints INT
 
 -- Get Pending Points
	 SELECT @iPendingPoints = PP.UserPendingPoints, @iBonusPoints = BonusPoints
	 FROM Loyalty..PendingPoints PP
		INNER JOIN Trip T ON T.UserKey = PP.UserId AND T.tripKey = PP.TripId
		AND T.tripKey = @tripKey AND T.UserKey = @userKey AND T.tripStatusKey <> 1 
	 
 IF @iPendingPoints IS NULL
	 BEGIN
	  -- Get Travel Points
	 SELECT @iTravelPoints = PP.UserPendingPoints, @iBonusPoints = BonusPoints
	 FROM [Loyalty].[dbo].[PendingPointsHistory] PP
		INNER JOIN Trip T ON T.UserKey = PP.UserId AND T.tripKey = PP.TripId AND PP.IsConverted = 1
		AND T.tripKey = @tripKey AND T.UserKey = @userKey AND T.tripStatusKey <> 1 
 END
 
 SELECT @iPendingPoints PendingPoints,@iBonusPoints BonusPoints, @iTravelPoints TravelPoints
END
GO
