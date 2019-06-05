SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SelfRegistrationGetCarVendorList]   
AS   
BEGIN   
  
 SELECT TOP 10 carVendorCode, carVendorName AS CarVendorName   
 FROM CarVendorLookup   
 ORDER BY carVendorCode  
   
END
GO
