SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant
-- Create date: 23rd Oct 2012
-- Description:	Getting Data For New Deals
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetResponseTripSavedDeal]
	-- Add the parameters for the stored procedure here
	@RequestKey Int
	,@GroupID Int
	,@Type Varchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;    
    
    If(@Type = 'CAR')
    Begin
		Select * from TripSavedDeals Where CONVERT(VARCHAR(6), creationDate, 12) = CONVERT(VARCHAR(6), GETDATE(), 12) 
		And componentType = 2 And Tripkey in (Select TripKey from CarRequestTripSavedDeal Where PkGroupId = @GroupID)
		Order By creationDate Desc
		
		Select carResponseKey,carRequestKey,carVendorKey,supplierId,carCategoryCode,carLocationCode  
		,carLocationCategoryCode,minRate,minRateTax,DailyRate,TotalChargeAmt,NoOfDays,RateQualifier,ReferenceType  
		,ReferenceDateTime,ReferenceId,MileageAllowance,RatePlan  
		From CarResponse Where carRequestKey = @RequestKey Order By minRate Asc
		
		Select carResponseDetailKey,carResponseKey,carVendorKey,supplierId,carCategoryCode  
		,carLocationCode,carLocationCategoryCode,minRate,minRateTax,totalPrice = ((minRate*NoOfDays) + minRateTax),NoOfDays,RateQualifier,ReferenceType,ReferenceDateTime  
		,ReferenceId,MileageAllowance,RatePlan,GuaranteeCode,SellGuaranteeReq,contractCode,PerDayPrice = (minRate + (minRateTax/NoOfDays))
		From CarResponseDetail Where carResponseKey in (Select carResponseKey From CarResponse Where carRequestKey = @RequestKey)
	End
	
	Else If(@Type = 'AIR')
	Begin
		Select * from TripSavedDeals Where CONVERT(VARCHAR(6), creationDate, 12) = CONVERT(VARCHAR(6), GETDATE(), 12) 
		And componentType = 1 And Tripkey in (Select TripKey from AirRequestTripSavedDeal Where PkGroupId = @GroupID)
		Order By creationDate Desc
		
		Select airResponseKey,airSubRequestKey,airPriceBaseDisplay,airPriceTaxDisplay,(airPriceBaseDisplay+airPriceTaxDisplay) as total
		,airPriceBaseTotal,airPriceTaxTotal
		From AirResponse Where airSubRequestKey = @RequestKey order by total asc
		
		Select airSegmentKey,airResponseKey,airLegNumber,segmentOrder,airSegmentMarketingAirlineCode,airSegmentOperatingAirlineCode,airSegmentFlightNumber 
		,airSegmentDepartureDate,airSegmentArrivalDate,airSegmentDepartureAirport,airSegmentArrivalAirport,airSegmentSeatRemaining,airSegmentOperatingFlightNumber
		,airsegmentCabin from AirSegments Where airResponseKey in (Select airResponseKey From AirResponse Where airSubRequestKey = @RequestKey)
	End
	
	Else If(@Type = 'HOTEL')
	Begin
		Select * from TripSavedDeals Where CONVERT(VARCHAR(6), creationDate, 12) = CONVERT(VARCHAR(6), GETDATE(), 12) 
		And componentType = 4 And Tripkey in (Select TripKey from HotelRequestTripSavedDeal Where PkGroupId = @GroupID)
		Order By creationDate Desc
		
		Select Distinct HR.HotelResponseKey,HR.HotelRequestKey,HR.SupplierHotelKey,HR.supplierId,HR.minRate,HR.minRateTax
		,HR.HotelsComType,HR.PreferenceOrder,HR.CorporateCode
		,VW_SHR.Rating,VW_SHR.RatingType,VW_SHR.ZipCode,HR.corporateCode,VW_SHR.HotelId
		From HotelResponse HR Inner Join vw_hotelDetailedResponseDeals VW_SHR
		On HR.hotelResponseKey = VW_SHR.hotelResponseKey
		Where HR.hotelRequestKey = @RequestKey
		
		Select * from HotelResponseDetail where hotelResponseKey in (Select hotelResponseKey from HotelResponse where hotelRequestKey = @RequestKey)
	End
	
END
GO
