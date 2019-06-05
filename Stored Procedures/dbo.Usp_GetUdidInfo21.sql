SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 22nd June 2012
-- Description:	
-- =============================================
--Exec [Usp_GetUdidInfo21]
CREATE PROCEDURE [dbo].[Usp_GetUdidInfo21]
	-- Add the parameters for the stored procedure here
	@SiteKey int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
 --   Declare @TmpUdid As Table (TripKey Int,RecordLocator Varchar(50),PassengerUDIDValue nVarchar(400))
    
 --   Insert Into @TmpUdid (TripKey,RecordLocator)
	--Select tripKey,recordLocator From Trip Where startDate >= GETDATE() And sitekey = @SiteKey
	
	--UPdate TU Set TU.PassengerUDIDValue = TPU.PassengerUDIDValue
	--From  @TmpUdid TU inner join TripPassengerUDIDInfo TPU on TU.TripKey = TPU.TripKey and TPU.CompanyUDIDNumber = 21
	
	--Select TripKey,RecordLocator,PassengerUDIDValue from @TmpUdid where PassengerUDIDValue is not null
	
	Declare @TmpUdid As Table (TripKey Int,RecordLocator Varchar(50),PassengerUDIDValue nVarchar(400))
	
	Insert into @TmpUdid(TripKey,RecordLocator,PassengerUDIDValue)
	Select Top 100 tripKey,recordLocator,PassengerUDIDValue from TripUdidUpdate 
	where isUpdate = 0 and sitecode = 'star'
	
	Update TripUdidUpdate Set isUpdate = 1 where tripKey in (Select TripKey from @TmpUdid)
	
	Select TripKey,RecordLocator,PassengerUDIDValue from @TmpUdid
	
END
GO
