SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create PROCEDURE [dbo].[USP_SaveAwardUpgradeValidatorData]
 @RecordLocator varchar(50),
 @ValidatorData varchar(max),
 @SiteKey int
AS

BEGIN  

IF EXISTS(select Id from Trip..AwardUpgradeValidatorDetails where RecordLocator= @RecordLocator and SiteKey=@SiteKey)
BEGIN
Delete from AwardUpgradeValidatorDetails where RecordLocator= @RecordLocator and SiteKey=@SiteKey 
END
insert into AwardUpgradeValidatorDetails(RecordLocator,ValidatorData,SiteKey) values
(@RecordLocator, @ValidatorData, @SiteKey)
END  
  
GO
