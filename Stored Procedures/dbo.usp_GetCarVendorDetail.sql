SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  CREATE PROCEDURE [dbo].[usp_GetCarVendorDetail]
  (@vendorCode varchar(5))
  As 
  SELECT CarCompanyName FROM  CarContent.dbo.CarCompanies where CarCompanyCode = @vendorCode 
  
GO
