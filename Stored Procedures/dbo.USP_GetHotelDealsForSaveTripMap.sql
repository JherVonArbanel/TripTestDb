SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author:  Jayant Guru  
-- Create date: 23rd July 2013  
-- Description: This stored procedure will get hotel details needed for save trip page based on tripkey.  
--    These data will be used to display the map in the save trip page  
-- =============================================  
--exec USP_GetHotelDealsForSaveTripMap 9920, 100  
CREATE PROCEDURE [dbo].[USP_GetHotelDealsForSaveTripMap]   
   
 @TripKey INT  
 ,@NumberOfDays INT = 5  
 ,@HotelIds VARCHAR(50) = ''  
   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
 DECLARE @Destination VARCHAR(3)  
   ,@AirportLatitude FLOAT  
   ,@AirportLongitude FLOAT  
   
 SET @Destination = (SELECT tripTo1 FROM TripRequest   
  WHERE TripRequestKey = (SELECT TripRequestKey FROM Trip WITH(NOLOCK) WHERE TripKey = @TripKey))  
    
  SELECT @AirportLatitude = Latitude, @AirportLongitude = Longitude   
  FROM AirportLookup WITH(NOLOCK) WHERE AirportCode = @Destination  
   
 IF(@HotelIds <> '')  
 BEGIN  
  DECLARE @TmpHotelID AS TABLE (HotelID INT)     
     
  INSERT @TmpHotelID (HotelID)         
  SELECT * FROM vault.dbo.ufn_CSVToTable (@HotelIds)  
    
  SELECT HotelId, HotelName, Rating, HT.Latitude, HT.Longitude, HT.Address1  
  , HT.Address2, HT.Address3, HT.CityName, HT.StateCode  
  ,HT.StateName, HT.ZipCode, HT.CountryCode, HT.PhoneNumber  
  , HT.FaxNumber, HT.WebsiteURL, HT.CityCode, HT.CheckInTime  
  , HT.CheckOutTime, AirportLatitude = @AirportLatitude  
  , AirportLongitude = @AirportLongitude, currentTotalPrice = 0  
  FROM HotelContent..Hotels HT WITH(NOLOCK)     
  WHERE HT.HotelId IN (SELECT HotelID FROM @TmpHotelID)  
    
 END  
 ELSE  
 BEGIN     
  DECLARE @TmpDeals TABLE (tripSavedDealKey INT, creationDate DATETIME, componentType INT)  
  DECLARE @Deals TABLE (vendorDetails VARCHAR(50), currentTotalPrice FLOAT  
  , AirResponseKey UNIQUEIDENTIFIER, AirportCode VARCHAR(3))  
    
  INSERT INTO @TmpDeals (tripSavedDealKey, creationDate, componentType)  
  SELECT TripSavedDealKey = MAX(TripSavedDealKey),creationDate = CONVERT(DATE,[creationDate]),componentType    
  FROM [dbo].[TripSavedDeals]  WITH(NOLOCK)     
  WHERE tripkey = @TripKey AND creationDate BETWEEN (GETDATE() - @NumberOfDays) AND GETDATE() AND componentType = 4  
  GROUP BY tripKey, CONVERT(DATE,[creationDate]),componentType  
     
  INSERT INTO @Deals (vendorDetails, currentTotalPrice, AirResponseKey)  
  SELECT vendorDetails, currentTotalPrice, responseKey FROM TripSavedDeals WITH(NOLOCK)   
  WHERE TripSavedDealKey IN (SELECT TripSavedDealKey FROM @TmpDeals)  
      
  SELECT HotelId, HotelName, Rating, HT.Latitude, HT.Longitude, HT.Address1  
  , HT.Address2, HT.Address3, HT.CityName, HT.StateCode  
  ,HT.StateName, HT.ZipCode, HT.CountryCode, HT.PhoneNumber  
  , HT.FaxNumber, HT.WebsiteURL, HT.CityCode, HT.CheckInTime  
  , HT.CheckOutTime, DL.currentTotalPrice, AirportLatitude = @AirportLatitude  
  , AirportLongitude = @AirportLongitude  
  FROM HotelContent..Hotels HT WITH(NOLOCK)  
  INNER JOIN   
  @Deals DL ON DL.vendorDetails = HT.HotelId  
 END       
END  
GO
