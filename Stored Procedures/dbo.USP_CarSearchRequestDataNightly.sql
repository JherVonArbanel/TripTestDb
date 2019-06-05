SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 28th June 2012
-- Description:	Gets the set of car request with common source, destination, date etc.
-- =============================================
--Exec USP_CarSearchRequestDataNightly 4,1
CREATE PROCEDURE [dbo].[USP_CarSearchRequestDataNightly]
	-- Add the parameters for the stored procedure here
	@BufferDays int
	,@SiteKey int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	Declare @TblGroup as table
	(
		PkGroupId int identity(1,1),TripRequestKey int,PickupCityCode Varchar(10)
		,DropOffCityCode Varchar(10),PickupDate DateTime,DropOffDate DateTime,TripSavedKey UniqueIdentifier
    )
  
    Insert Into CarRequestNightly(TripKey,TripSavedKey,TripRequestKey,CarCategoryCode,PickupCityCode,DropOffCityCode,PickupDate
    ,DropOffDate,ActualCarPrice,ActualCarTax,NoOfDays)
    Select TR.tripKey,TS.tripSavedKey,TR.tripRequestKey,TCR.carCategoryCode,PickUpCityCode = TCR.carLocationCode,DropOffCityCode = TCR.carLocationCode
    ,convert(Datetime,convert(Varchar(20),TCR.pickUpDate ,103),103),convert(Datetime,convert(Varchar(20),TCR.dropOutDate ,103),103)
    ,TCR.actualCarPrice,TCR.actualCarTax,TCR.NoOfDays 
    from TripCarResponse TCR
    Inner Join TripSaved TS On TS.tripSavedKey = TCR.tripGUIDKey
	Inner Join Trip TR On TR.tripSavedKey = TS.tripSavedKey
	Where TR.tripKey NOT IN
	(SELECT T.tripKey From trip T  Inner Join TripCarResponse TH On t.tripPurchasedKey = th.tripGUIDKey And Th.isDeleted = 0)
	--And TR.siteKey = @SiteKey
	--And CONVERT(VARCHAR(10), TCR.pickUpDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
    	
	Insert Into @TblGroup (PickupCityCode,DropOffCityCode,PickupDate,DropOffDate,TripSavedKey)
	Select Distinct PickupCityCode,DropOffCityCode,PickupDate,DropOffDate,TripSavedKey 
	From CarRequestNightly
	
	Update CRN Set
	CRN.PkGroupId = GRP.PkGroupId
	From CarRequestNightly CRN
	left outer join @TblGroup GRP On
	GRP.PickupCityCode = CRN.PickupCityCode
	and GRP.DropOffCityCode = CRN.DropOffCityCode 
	and GRP.PickupDate = CRN.PickupDate
	and GRP.DropOffDate = CRN.DropOffDate
	
	Select PkGroupId From @TblGroup Order By PkGroupId
	
END
GO
