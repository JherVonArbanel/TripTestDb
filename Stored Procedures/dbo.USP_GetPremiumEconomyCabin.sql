SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Hemali Desai
-- Create date: Feb 12,2013
-- Description:	GetPremiumEconomyCabin for One World
-- EXEC USP_GetPremiumEconomyCabin 'AA', 'Q'
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetPremiumEconomyCabin]
	AS
BEGIN
	SET NOCOUNT ON;
	SELECT airVendorCode, bookingClass
	FROM   airlineCabin
END
GO
