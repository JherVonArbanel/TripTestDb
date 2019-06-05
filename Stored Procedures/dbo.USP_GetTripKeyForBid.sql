SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 18th May 2012
-- Description:	Gets all the active trip key and inserts it temporarily in TempBidTripKey
--EXEC USP_GetTripKeyForBid 6
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripKeyForBid]
	-- Add the parameters for the stored procedure here
	@SiteKey int,
	@BufferDays int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	insert into TempBidTripKey(TripRequestKey,TripKey)
	SELECT tripRequestKey, tripKey FROM Trip 
	WHERE tripStatusKey = 2 AND siteKey = @SiteKey 
	AND CONVERT(VARCHAR(10), startDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120)) --and isBid = 1(will be used later)
	SELECT PkID, TripRequestKey, TripKey, IsExecuted FROM TempBidTripKey
END
GO
