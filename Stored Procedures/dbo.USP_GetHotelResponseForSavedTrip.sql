SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[USP_GetHotelResponseForSavedTrip]    
(    
@hotelresponseKey uniqueidentifier    
)    
AS     
if ( SELECT COUNT(*) FROM NightlyDealProcess where responseKey = @hotelresponseKey )= 0     
BEGIN     
select distinct hotelresponsekey ,supplierhotelkey,supplierID,hotelname,rating,ratingtype,chaincode,hotelid,latitude,longitude,address1,cityname,citycode,statecode,countrycode,zipcode,PhoneNumber, Faxnumber,Distance, checkindate,checkoutdate,hoteldescription,chainName,searchhotelprice as minrate,searchhotelTax as minratetax , 1 as isactualshoppingCart,hoteldailyprice , hoteltaxRate,hotelTotalPrice,hotelrateplancode,guaranteeCode,hotelrateplancode,ratedescription,cancellationPolicy,roomAmenities FROM vw_TripHotelResponse where hotelResponseKey =@hotelresponseKey     
END     
ELSE     
BEGIN      
select distinct VW.hotelresponsekey ,VW.supplierhotelkey,vW.supplierID,hotelname,rating,ratingtype,chaincode,hotelid,latitude,longitude,address1,cityname,citycode,statecode,countrycode,zipcode,PhoneNumber,Faxnumber,Distance, checkindate,checkoutdate,isnull(HD.hoteldescription, vw.HotelDescription ) as HotelDescription ,chainName,minrate,minratetax , 0 as isactualshoppingCart
 ,isnull(hoteldailyprice,minRate) hoteldailyprice , isnull(hoteltaxRate,0) hoteltaxRate,isnull(hotelTotalPrice,0) hotelTotalPrice,hotelrateplancode,guaranteeCode,hotelrateplancode,ratedescription,cancellationPolicy,roomAmenities 
FROM vw_hotelDetailedResponse1 VW
INNER JOIN 
TripSavedDeals N on vw.hotelResponseKey = N.responseKey 
left outer join 
HotelResponseDetail HD on (N.responseDetailKey = HD.hotelResponseDetailKey )
where VW.hotelResponseKey =@hotelresponseKey
     END
GO
