SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- Updated on 30-06-2016 by Manoj Naik	
-- Description: Only trip created by user will run DOD not automated. Also purchased and cancelled trips are removed.

--Exec USP_TripSavedDealHotelSearchRequestData 2,5
CREATE PROCEDURE [dbo].[USP_TripSavedDealHotelSearchRequestData]
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
		PkGroupId int identity(1,1),TripRequestKey int,NoOfRooms int
		,HotelCityCode Varchar(6),CheckInDate DateTime,CheckOutDate DateTime,TripKey int
    )
    --Declare @TblRequestCityCode as table(TripRequestKey int,HotelRequestKey int,HotelCityCode Varchar(6))
    Declare @CityCodeNullCount int
			,@MaxGroupid int
    
    Insert Into HotelRequestTripSavedDeal(TripKey,TripRequestKey,NoOfDays,NoOfRooms,HotelCityCode,CheckInDate,CheckOutDate,TripStatusKey,UserKey,
	Rating,RatingType,Latitude,Longitude,StateCode,CountryCode,ZipCode,TripSavedKey,TripAdultsCount,TripSeniorsCount,TripChildCount
	,TripInfantCount,TripYouthCount,NoOfTotalTraveler,OriginalSearchToCity)
    Select TripKey,TripRequestKey,DATEDIFF(day, CONVERT(VARCHAR(10), checkInDate, 120), CONVERT(VARCHAR(10), checkOutDate, 120)),ISNULL(noOfRooms,1)
    ,CityCode,CheckInDate,CheckOutDate,TripStatusKey,UserKey,
	Rating,RatingType,Latitude,Longitude,StateCode,CountryCode,ZipCode,tripSavedKey,TripAdultsCount,TripSeniorsCount
	,TripChildCount,TripInfantCount,TripYouthCount,NoOfTotalTraveler,ISNULL(tripTo1,CityCode)
    From vw_TripSavedHotelResponse
    Where CONVERT(VARCHAR(10), checkInDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
    And siteKey = @SiteKey And tripRequestKey <> 0 AND tripStatusKey NOT IN (17,4,5) AND isUserCreatedSavedTrip = 1 --And cityCode <> ''
    AND ISNULL(userKey, 0) > 0
    --and LEN(cityCode) <= 3
        
    Set @CityCodeNullCount = (Select COUNT(*) From HotelRequestTripSavedDeal Where HotelCityCode IS NULL OR HotelCityCode = '')
    
    If(@CityCodeNullCount > 0)
    Begin
		Update HRN Set
		HRN.HotelCityCode = TR.tripTo1
		From HotelRequestTripSavedDeal HRN
		Inner Join TripRequest TR On
		TR.tripRequestKey = HRN.TripRequestKey
		Where HRN.HotelCityCode IS NULL OR HRN.HotelCityCode = ''
    End
    
    Insert Into @TblGroup (TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate,TripKey,NoOfRooms)
	Select Distinct TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate,TripKey,NoOfRooms
	From HotelRequestTripSavedDeal order by TripKey desc
	
	UPDATE ARTS SET
	ARTS.CountryName = CL.CountryName
	,ARTS.CityName = AL.CityName
	FROM HotelRequestTripSavedDeal ARTS
	LEFT OUTER JOIN AirportLookup AL WITH (NOLOCK)
	ON AL.AirportCode = ARTS.OriginalSearchToCity
	LEFT OUTER JOIN vault..CountryLookUp CL WITH (NOLOCK)
	ON CL.CountryCode = AL.CountryCode	
	
	Update HRN Set
	HRN.PkGroupId = GRP.PkGroupId
	From HotelRequestTripSavedDeal HRN
	Left Outer Join @TblGroup GRP On
	GRP.HotelCityCode = HRN.HotelCityCode
	and GRP.CheckInDate = HRN.CheckInDate
	and GRP.CheckOutDate = HRN.CheckOutDate
	and GRP.NoOfRooms = HRN.NoOfRooms
	and HRN.Rating >= (Select StarRatingConsideration From DealsThresholdSettings Where ComponentTypeKey = 4)
	
	Set @MaxGroupid = ((Select ISNULL(MAX(PkGroupId),0) from HotelRequestTripSavedDeal) + 1)
	
	Update HotelRequestTripSavedDeal Set PkGroupId = @MaxGroupid Where Rating 
	< (Select StarRatingConsideration From DealsThresholdSettings Where ComponentTypeKey = 4)
	
	--Select PkGroupId,TripRequestKey,TripKey From @TblGroup Order By TripKey Desc
	
	Declare @DisGroup As Table (PkGroupId INT)
	Insert Into @DisGroup (PkGroupId) Select Distinct PkGroupId FROM HotelRequestTripSavedDeal

	Declare @DisGroupFinal As Table (PkGroupId INT, TripRequestKey INT, TripKey INT)
	Insert into @DisGroupFinal (PkGroupId, TripRequestKey, TripKey)
	Select t.PKGroupID, MAX(TripRequestKey), MAX(TripKey) FROM HotelRequestTripSavedDeal H INNER JOIN @DisGroup t ON H.PkGroupId = t.PkGroupId GROUP BY t.PkGroupId
		
	Select PkGroupId, TripRequestKey, TripKey from @DisGroupFinal order by TripKey desc
	
	--Insert Into HotelRequestTripSavedDeal(TripKey,TripRequestKey,NoOfRooms,HotelCityCode,CheckInDate,CheckOutDate)
	--Select TR.tripKey,TR.tripRequestKey,HR.NoofRooms,HR.hotelCityCode
	--,HR.checkInDate,HR.checkOutDate from trip TR
	--Inner Join TripHotelResponse THR on TR.tripKey = THR.tripKey
	--Inner Join TripRequest_hotel TR_H on TR_H.tripRequestKey = TR.tripRequestKey
	--Inner Join HotelRequest HR on HR.hotelRequestKey = TR_H.hotelRequestKey
	--and CONVERT(VARCHAR(10), THR.checkInDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
	--and THR.recordLocator <> '' and THR.recordLocator is not null
	
	--Insert Into @TblGroup (TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate)
	--Select Distinct TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate
	--From HotelRequestTripSavedDeal
	
	--Update HRN Set
	--HRN.PkGroupId = GRP.PkGroupId
	--From HotelRequestTripSavedDeal HRN
	--Left Outer Join @TblGroup GRP On
	--GRP.TripRequestKey = HRN.TripRequestKey
	--and GRP.HotelCityCode = HRN.HotelCityCode
	--and GRP.CheckInDate = HRN.CheckInDate
	--and GRP.CheckOutDate = HRN.CheckOutDate
	
	--Select PkGroupId,TripRequestKey From @TblGroup Where TripRequestKey <> 0 Order By PkGroupId
	
END
GO
