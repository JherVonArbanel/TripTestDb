SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================    
-- Author:  Pradeep Gupta  
-- Create date: 15 Mar 2017
-- Description: Saves first day savetrip option for Air/Car/Hotel    
-- =============================================    
CREATE PROCEDURE [dbo].[USP_InsertSaveTripDealsforAddComponent]     
 @hasAir BIT = 0    
 ,@hasCar BIT = 0    
 ,@hasHotel BIT = 0    
 ,@tripKey BIGINT    
   
 /*##########AIR##########*/    
 ,@latestDealAirSavingsPerPerson FLOAT = 0    
 ,@latestDealAirSavingsTotal FLOAT = 0    
 ,@latestDealAirPricePerPerson FLOAT = 0  --  
 ,@latestDealAirPriceTotal FLOAT = 0  --   
 ,@airRequestTypeName VARCHAR(50) = ''    
 ,@airCabin VARCHAR(50) = ''    
 ,@latestAirLineCode VARCHAR(30) = ''    
 ,@latestAirlineName VARCHAR(64) = ''    
 ,@numberOfCurrentAirStops INT = 0    
 ,@airResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'   --  
 ,@originalPerPersonPriceAir FLOAT = 0  --  
 ,@originalTotalPriceAir FLOAT = 0   --  
 ,@vendorDetailsAir VARCHAR(100) = ''   --  
  
 /*##########HOTEL##########*/    
 ,@latestDealHotelSavingsPerPerson FLOAT  = 0    
 ,@latestDealHotelSavingsTotal FLOAT  = 0    
 ,@latestDealHotelPricePerPerson FLOAT  = 0  --   
 ,@latestDealHotelPriceTotal FLOAT  = 0  --  
 ,@latestDealHotelPricePerPersonPerDay FLOAT  = 0    
 ,@hotelDailyPriceOriginal FLOAT  = 0    
 ,@hotelPricePerPersonOriginal FLOAT  = 0   --  
 ,@hotelPriceTotalOriginal FLOAT  = 0  --  
 ,@hotelPricePerPersonPerDayOriginal FLOAT  = 0    
 ,@latestHotelRegionId INT = 0    
 ,@latestHotelId INT = 0    
 ,@latestHotelChainCode VARCHAR(20) = ''    
 ,@currentHotelsComId VARCHAR(10) = ''    
 ,@hotelResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'   --  
 ,@hotelName VARCHAR(100) = ''    
 ,@hotelRating FLOAT  = 0    
 ,@hotelRegionName VARCHAR(50) = ''    
 ,@vendorDetailsHotel VARCHAR(30) = ''   --  
 ,@noOfRooms INT = 0    
 ,@hotelNoOfDays INT = 0    
  
 /*##########CAR##########*/    
 ,@latestDealCarSavingsPerDay FLOAT = 0    
 ,@latestDealCarSavingsTotal FLOAT = 0    
 ,@latestDealCarPricePerDay FLOAT = 0    
 ,@latestDealCarPriceTotal FLOAT = 0    
 ,@originalPerDayPriceCar FLOAT = 0    
 ,@originalTotalPriceCar FLOAT = 0    
 ,@carClass VARCHAR(50) = ''    
 ,@carVendorCode VARCHAR(2) = ''    
 ,@latestCarVendorName VARCHAR(30) = ''    
 ,@carResponseKey UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'    
     
AS    
BEGIN     
 SET NOCOUNT ON;    
     
 DECLARE @remarks VARCHAR(50)   
    
 SET @remarks = 'First day deal'    
     
 --FOR AIR    
 IF(@hasAir = 1)    
 BEGIN      
  IF (select COUNT(*) from Trip..TripSavedDeals with (nolock) where tripKey = @tripKey and componentType = 1) <=0  
  BEGIN    
   print 'air found'  
   Insert Into TripSavedDeals     
  (    
   tripKey    
   ,responseKey    
   ,componentType    
   ,currentPerPersonPrice    
   ,originalPerPersonPrice    
   ,fareCategory    
   ,isAlternate    
   ,vendorDetails    
   ,currentTotalPrice    
   ,originalTotalPrice    
   ,Remarks    
  )    
  VALUES    
  (    
   @tripKey    
   ,@airResponseKey    
   ,1    
   ,@latestDealAirPricePerPerson    
   ,@originalPerPersonPriceAir    
   ,'Publish'    
   ,1    
   ,@vendorDetailsAir    
   ,@latestDealAirPriceTotal    
   ,@originalTotalPriceAir    
   ,@remarks    
  )       
  END    
  ELSE    
  BEGIN    
   print 'no air found'  
  END    
      
      
 END    
     
 --FOR HOTEL    
 IF(@hasHotel = 1)    
 BEGIN      
  IF (select COUNT(*) from Trip..TripSavedDeals with (nolock) where tripKey = @tripKey and componentType = 4) <=0  
  BEGIN    
     
   INSERT INTO TripSavedDeals     
  (    
   tripKey    
   ,responseKey    
   ,componentType    
   ,currentPerPersonPrice    
   ,originalPerPersonPrice    
   ,fareCategory    
   ,isAlternate    
   ,vendorDetails    
   ,currentTotalPrice    
   ,originalTotalPrice    
   ,responseDetailKey    
   ,Remarks    
  )    
  VALUES    
  (    
   @tripKey    
   ,@hotelResponseKey    
   ,4    
   ,@latestDealHotelPricePerPerson    
   ,@hotelPricePerPersonOriginal    
   ,'Publish'    
   ,1    
   ,@vendorDetailsHotel    
   ,@latestDealHotelPriceTotal    
   ,@hotelPriceTotalOriginal    
   ,@hotelResponseKey    
   ,@remarks    
  )   
     
  END    
  ELSE    
  BEGIN    
  print 'no record found for hotel'   
  END    
      
     
      
 END    
     
 --FOR CAR    
 IF(@hasCar = 1)    
 BEGIN      
  IF (select COUNT(*) from Trip..TripSavedDeals with (nolock) where tripKey = @tripKey and componentType = 2) <=0  
  BEGIN    
   INSERT INTO TripSavedDeals     
  (    
   tripKey    
   ,responseKey    
   ,componentType    
   ,currentPerPersonPrice    
   ,originalPerPersonPrice    
   ,fareCategory    
   ,responseDetailKey    
   ,isAlternate    
   ,vendorDetails    
   ,currentTotalPrice    
   ,originalTotalPrice    
   ,Remarks    
  )    
  VALUES    
  (    
   @tripKey    
   ,@carResponseKey    
   ,2    
   ,@latestDealCarPricePerDay    
   ,@originalPerDayPriceCar    
   ,'Publish'    
   ,@carResponseKey    
   ,1    
   ,@carVendorCode    
   ,@latestDealCarPriceTotal    
   ,@originalTotalPriceCar    
   ,@remarks    
  )    
  END    
  ELSE    
  BEGIN    
   print 'no record found for car'  
  END    
      
     
 END    
     
END
GO
