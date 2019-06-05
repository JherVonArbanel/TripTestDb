SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CarVendorLookup_GET] 
AS 
BEGIN 

	SELECT 
		carVendorCode,
		carVendorName 
	FROM CarVendorLookup 
	ORDER BY carVendorName ASC

END
GO
