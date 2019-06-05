SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 13-08-2015
-- Description:	 Verify user use of specific promo code - single use only.
-- =============================================
CREATE PROCEDURE [dbo].[USP_VerifyPromoByUserId] 
	-- Add the parameters for the stored procedure here
	@userId int, 
	@promoId int
AS
BEGIN

	IF EXISTS(SELECT tripKey FROM Trip.dbo.Trip WHERE userKey = @userId AND promoId = @promoId ) 
      SELECT 'TRUE' 
    ELSE 
      SELECT 'FALSE'

END
GO
