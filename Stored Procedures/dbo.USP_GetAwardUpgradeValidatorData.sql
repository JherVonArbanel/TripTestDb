SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create   PROCEDURE [dbo].[USP_GetAwardUpgradeValidatorData]
@RecordLocator varchar(50),
@SiteKey int
AS
BEGIN
    SELECT *
	FROM 
		AwardUpgradeValidatorDetails 
	WHERE  
		RecordLocator = @RecordLocator 
		AND SiteKey=@SiteKey
END
GO
