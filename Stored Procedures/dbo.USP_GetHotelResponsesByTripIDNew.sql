SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_GetHotelResponsesByTripIDNew]          
(          
 @tripKey   INT = NULL,          
 @hotelResponseKey UNIQUEIDENTIFIER          
)          
AS          
BEGIN          
          
 IF @tripKey IS NOT NULL          
 BEGIN          
  SELECT           
   vw_hotelDetailedResponse1.*,           
   TriphotelResponse.*           
  FROM vw_hotelDetailedResponse1           
   LEFT OUTER JOIN TriphotelResponse WITH(NOLOCK) ON vw_hotelDetailedResponse1.hotelResponseKey = TriphotelResponse.hotelResponseKey           
  WHERE tripKey = @tripKey          
 END          
 ELSE          
 BEGIN    
   
 DECLARE @corporateCode varchar(100),@companyContract as Varchar(100), @hotelKey int, @hotelRequestId int    
    
 SELECT  @hotelKey = hotelId , @hotelRequestId = hotelRequestKey  FROM [Trip].[dbo].[HotelResponse] WHERE hotelResponseKey = @hotelResponseKey     
  
 SELECT top 1 @corporateCode = corporateCode from [Trip].[dbo].[HotelResponse] where  supplierId='Sabre' and( corporateCode is not null AND corporateCode !='')  and hotelId = @hotelKey  and hotelRequestKey = @hotelRequestId    
 SELECT top 1 @companyContract = CompanyContractApplied FROM [Trip].[dbo].[HotelResponse] where  supplierId='Sabre' and( CompanyContractApplied is not null AND CompanyContractApplied !='')  and hotelId = @hotelKey  and hotelRequestKey = @hotelRequestId           
  --group by minRate,corporateCode  order by  Min(minRate)   
         
  SELECT top 100 contractCode =@corporateCode ,@companyContract as CompanyContractApplied,  * FROM vw_hotelDetailedResponse1 WHERE hotelResponseKey = @hotelResponseKey          
 END          
          
END 
GO
