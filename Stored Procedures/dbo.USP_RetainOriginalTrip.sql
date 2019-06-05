SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 07-05-2016 12:20
-- Description:	Retain original trip.
-- =============================================
CREATE PROCEDURE [dbo].[USP_RetainOriginalTrip]
	-- Add the parameters for the stored procedure here
	@tripId bigint
AS
BEGIN
	
	UPDATE Trip..Trip SET RetainOrReplace = GETDATE() WHERE tripKey=@tripId
	
END
GO
