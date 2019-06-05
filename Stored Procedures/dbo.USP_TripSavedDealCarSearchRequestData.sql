SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 28th June 2012
-- Description:	Gets the set of car request with common source, destination, date etc.
-- Updated on 30-06-2016 by Manoj Naik	
-- Description: Only trip created by user will run DOD not automated. Also purchased and cancelled trips are removed.

-- =============================================
--Exec USP_CarSearchRequestDataNightly 4,1
CREATE PROCEDURE [dbo].[USP_TripSavedDealCarSearchRequestData]
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
		,DropOffCityCode Varchar(10),PickupDate DateTime,DropOffDate DateTime,TripSavedKey UniqueIdentifier,TripKey int
    )
  
    Insert Into CarRequestTripSavedDeal(TripKey,TripSavedKey,TripRequestKey,CarCategoryCode,PickupCityCode,DropOffCityCode,PickupDate
    ,DropOffDate,ActualCarPrice,ActualCarTax,NoOfDays,MinRate,MinRateTax,UserKey)
    Select TR.tripKey,TS.tripSavedKey,TR.tripRequestKey,TCR.carCategoryCode,PickUpCityCode = TCR.carLocationCode,DropOffCityCode = TCR.carLocationCode
    ,convert(Datetime,convert(Varchar(20),TCR.pickUpDate ,103),103),convert(Datetime,convert(Varchar(20),TCR.dropOutDate ,103),103)
    ,TCR.actualCarPrice,TCR.actualCarTax,TCR.NoOfDays,TCR.minRate,TCR.minRateTax, TR.userKey 
    from TripCarResponse TCR
    Inner Join TripSaved TS On TS.tripSavedKey = TCR.tripGUIDKey
	Inner Join Trip TR On TR.tripSavedKey = TS.tripSavedKey
	Where CONVERT(VARCHAR(10), TCR.pickUpDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
	And TR.siteKey = @SiteKey
	And ISNULL(TR.userKey, 0) > 0 AND TR.isUserCreatedSavedTrip = 1 AND TR.tripStatusKey NOT IN (17,4,5)
	--And TR.tripKey NOT IN
	--(SELECT T.tripKey From trip T  Inner Join TripCarResponse TH On t.tripPurchasedKey = th.tripGUIDKey And Th.isDeleted = 0)
	
    	
	Insert Into @TblGroup (PickupCityCode,DropOffCityCode,PickupDate,DropOffDate,TripSavedKey,TripKey)
	Select Distinct PickupCityCode,DropOffCityCode,PickupDate,DropOffDate,TripSavedKey,TripKey
	From CarRequestTripSavedDeal
	
	UPDATE ARTS SET
	ARTS.FromCountryCode = AL.CountryCode
	,ARTS.FromCountryName = CL.CountryName
	,ARTS.FromStateCode = AL.StateCode
	,ARTS.FromCityName = AL.CityName
	,ARTS.ToCountryCode = ALC.CountryCode
	,ARTS.ToCountryName = CLC.CountryName 
	,ARTS.ToStateCode = ALC.StateCode
	,ARTS.ToCityName = ALC.CityName
	FROM CarRequestTripSavedDeal ARTS
	LEFT OUTER JOIN AirportLookup AL WITH (NOLOCK)
	ON AL.AirportCode = ARTS.PickupCityCode
	LEFT OUTER JOIN AirportLookup ALC WITH (NOLOCK)
	ON ALC.AirportCode = ARTS.DropOffCityCode
	LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)
	ON CL.CountryCode = AL.CountryCode
	LEFT OUTER JOIN vault..CountryLookUp CLC WITH (NOLOCK)
	ON CLC.CountryCode = ALC.CountryCode
	
	Update CRN Set
	CRN.PkGroupId = GRP.PkGroupId
	From CarRequestTripSavedDeal CRN
	left outer join @TblGroup GRP On
	GRP.PickupCityCode = CRN.PickupCityCode
	and GRP.DropOffCityCode = CRN.DropOffCityCode 
	and GRP.PickupDate = CRN.PickupDate
	and GRP.DropOffDate = CRN.DropOffDate
	
	Declare @DisGroup As Table (PkGroupId INT)
	
	Insert Into @DisGroup (PkGroupId) Select Distinct PkGroupId FROM CarRequestTripSavedDeal
	
	Declare @DisGroupFinal As Table (PkGroupId INT, TripKey INT)
	
	Insert into @DisGroupFinal (PkGroupId, TripKey)
	Select t.PKGroupID, MAX(TripKey) FROM CarRequestTripSavedDeal H 
	INNER JOIN @DisGroup t ON H.PkGroupId = t.PkGroupId GROUP BY t.PkGroupId
	
	Select PkGroupId, TripKey from @DisGroupFinal order by TripKey desc
	--Select PkGroupId From @TblGroup Order By TripKey Desc
	
END
GO
