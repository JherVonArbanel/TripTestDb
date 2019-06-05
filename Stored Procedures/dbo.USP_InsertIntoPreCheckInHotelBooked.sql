SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[USP_InsertIntoPreCheckInHotelBooked]    
           @UploadKey uniqueidentifier,
           @PNR nvarchar(10),    
           @CID nvarchar(50),    
           @CName nvarchar(50),    
           @Chain nvarchar(50),    
           @SabreID nvarchar(50),    
           @TouricoID nvarchar(50),    
           @EANID nvarchar(50),  
           @HotelName nvarchar(50),    
           @Nights nchar(10),    
           @RoomType nchar(10),    
           @Rate nvarchar(50),                                     
           @Currency nvarchar(50),    
           @Total nchar(30),    
           @Traveler nvarchar(50),                                     
           @CheckIn nvarchar(50),    
           @CheckOut nvarchar(50),    
           @CityName nvarchar(50),    
           @Cancellation nvarchar(50),                                                           
           @Phone nvarchar(50),
           @CreatedDate datetime               
    
AS    
    
INSERT INTO [Trip].[dbo].[PreCheckInHotelBooked]    
           (
           UploadKey,
           PNR,    
           CID,    
           CName,    
           Chain,    
           SabreID,    
           TouricoID,  
           EANID,    
           HotelName,    
           Nights,  
           RoomType,    
           Rate,                                     
           Currency,    
           Total,    
           Traveler ,                                     
           CheckIn,    
           CheckOut,    
           CityName ,    
           Cancellation ,                                                           
           Phone,
           CreatedDate)    
     VALUES    
           (
           @UploadKey,
           @PNR ,    
           @CID ,    
           @CName ,    
           @Chain ,    
           @SabreID ,    
           @TouricoID,    
           @EANID,  
           @HotelName ,    
           @Nights ,   
           @RoomType,   
           @Rate ,                                     
           @Currency,    
           @Total ,    
           @Traveler,                                     
           @CheckIn ,    
           @CheckOut,    
           @CityName ,    
           @Cancellation,                                                           
           @Phone,
           @CreatedDate )
GO
