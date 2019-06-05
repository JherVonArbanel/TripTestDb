SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 03-10-2016
-- Description:	Get list of uploaded file key with date order.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetPreCheckInHotelBookedUploadKeyList]
AS
BEGIN
   SELECT UploadKey,CreatedDate FROM Trip..PreCheckInHotelBooked Group By UploadKey,CreatedDate Order by CreatedDate DESC
END
GO
