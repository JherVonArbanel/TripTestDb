SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--exec [USP_ValidateDKandPCC]
CREATE PROCEDURE [dbo].[USP_ValidateDKandPCC]
(
	-- DECLARE
	 @DKNumber Varchar(50)='CF35445656'
	,@PCC  Varchar(5)='XX0G'
)
AS
BEGIN

Declare @ValidPCC bit=0
Declare @PCC_DK Varchar(50)

SELECT @PCC_DK=CC.PCC
FROM Vault.dbo.DK D
				INNER JOIN	Vault.dbo.company C On D.companykey=C.companykey
				INNER JOIN	vault..CompanyCultureConfiguration CC ON C.companykey=CC.companykey
				WHERE D.number=@DKNumber
--select @PCC_DK,@PCC

	IF @PCC_DK=@PCC
	BEGIN
		SET @ValidPCC=1
	END
	ELSE
	BEGIN
		SET @ValidPCC=0
	END

SELECT @ValidPCC

END

--select * from vault..CompanyCultureConfiguration where companykey=10712 order by 1 desc
--select * from vault..company where companykey=10712
--select * from vault..DK  where companykey=10712
GO
