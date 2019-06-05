SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 2nd July 2012
-- Description:	<Description,,>
-- =============================================
--Exec [USP_HotelSearchRequestDataNightly] 4, 6
CREATE PROCEDURE [dbo].[USP_HotelSearchRequestDataNightly]
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
		,HotelCityCode Varchar(6),CheckInDate DateTime,CheckOutDate DateTime
    )
    
    Insert Into HotelRequestNightly(TripKey,TripRequestKey,NoOfDays,NoOfRooms,HotelCityCode,CheckInDate,CheckOutDate,TripStatusKey,UserKey,
	Rating,RatingType,Latitude,Longitude,StateCode,CountryCode,ZipCode)
    Select TripKey,TripRequestKey,DATEDIFF(day, CONVERT(VARCHAR(10), checkInDate, 120), CONVERT(VARCHAR(10), checkOutDate, 120)),1
    ,CityCode,CheckInDate,CheckOutDate,TripStatusKey,UserKey,
	Rating,RatingType,Latitude,Longitude,StateCode,CountryCode,ZipCode
    From vw_TripSavedHotelResponse    
    Where CONVERT(VARCHAR(10), checkInDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
    And siteKey = @SiteKey And tripRequestKey <> 0
    --And cityCode <> '' and LEN(cityCode) <= 3
    
    Insert Into @TblGroup (TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate)
	Select Distinct TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate
	From HotelRequestNightly
	
	Update HRN Set
	HRN.PkGroupId = GRP.PkGroupId
	From HotelRequestNightly HRN
	Left Outer Join @TblGroup GRP On
	GRP.HotelCityCode = HRN.HotelCityCode
	and GRP.CheckInDate = HRN.CheckInDate
	and GRP.CheckOutDate = HRN.CheckOutDate
	
	--Select PkGroupId,TripRequestKey From @TblGroup Order By PkGroupId
	Select PkGroupId,TripRequestKey From @TblGroup Order By PkGroupId Desc
    
	--Insert Into HotelRequestNightly(TripKey,TripRequestKey,NoOfRooms,HotelCityCode,CheckInDate,CheckOutDate)
	--Select TR.tripKey,TR.tripRequestKey,HR.NoofRooms,HR.hotelCityCode
	--,HR.checkInDate,HR.checkOutDate from trip TR
	--Inner Join TripHotelResponse THR on TR.tripKey = THR.tripKey
	--Inner Join TripRequest_hotel TR_H on TR_H.tripRequestKey = TR.tripRequestKey
	--Inner Join HotelRequest HR on HR.hotelRequestKey = TR_H.hotelRequestKey
	--and CONVERT(VARCHAR(10), THR.checkInDate, 120) > (CONVERT(VARCHAR(10), DATEADD(DAY,@BufferDays,GETDATE()), 120))
	--and THR.recordLocator <> '' and THR.recordLocator is not null
	
	--Insert Into @TblGroup (TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate)
	--Select Distinct TripRequestKey,HotelCityCode,CheckInDate,CheckOutDate
	--From HotelRequestNightly
	
	--Update HRN Set
	--HRN.PkGroupId = GRP.PkGroupId
	--From HotelRequestNightly HRN
	--Left Outer Join @TblGroup GRP On
	--GRP.TripRequestKey = HRN.TripRequestKey
	--and GRP.HotelCityCode = HRN.HotelCityCode
	--and GRP.CheckInDate = HRN.CheckInDate
	--and GRP.CheckOutDate = HRN.CheckOutDate
	
	--Select PkGroupId,TripRequestKey From @TblGroup Where TripRequestKey <> 0 Order By PkGroupId
	
END
GO
