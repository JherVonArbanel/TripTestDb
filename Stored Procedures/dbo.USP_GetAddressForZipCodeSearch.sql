SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Ashima Gupta
-- Create date: 07-04-2016 06:22 pm
-- Description:	Get address details from postal code table id.
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAddressForZipCodeSearch]

	@ID INT = 0
AS
BEGIN
   SELECT * FROM HotelAutoCompleteForZipCodeSearch WHERE Id = @ID
	
END
GO
