SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_SelectCompanyUDID]
(  
	@udidOptionText NVARCHAR(50), 
	@companyUDIDNumber INT, 
	@userKey INT
)
AS  
  
BEGIN  

	SELECT CU.companyUDIDKey,CU.companyUDIDDescription,CU.companyUDIDEntryType,CU.textEntryType, 
		CU.isPrintOnInvoice,CUO.companyUDIDOptionsKey,CUO.udidOptionText,CUO.udidOptionCode 
    FROM Vault.dbo.CompanyUDID CU 
		INNER JOIN Vault.dbo.CompanyUDIDOptions CUO ON CU.companyUDIDKey = CUO.companyUDIDKey AND CUO.udidOptionText = @udidOptionText 
    WHERE CU.companyUDIDNumber = @companyUDIDNumber AND CU.companyKey = (SELECT companyKey FROM Vault.dbo.[User] WHERE userKey = @userKey)
 
END  

GO
