SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 27-08-2015 19:09
-- Description:	Add trip promotion history after booking.
-- =============================================
CREATE PROCEDURE [dbo].[USP_AddTripPromotionHistory]
 -- Add the parameters for the stored procedure here  
    @PromoId int,       
	@PromoCampaignName VARCHAR(50) =null,            
	@PublicCode VARCHAR(100) =null,            
	@PromoCampaignType varchar(100) =null,          
	@DiscountRate varchar(10) =null,          
	@UsageRestriction varchar(20) =null,          
	@OfferMatchType varchar(100) =null,          
	@HotelVenorMatch varchar(50) =null,          
	@HotelChainMatch varchar(50) =null,          
	@HotelGroupMatch varchar(50) =null,          
	@CitySpecificMatch varchar(50) =null,          
	@SpecificAirportCodeMatch varchar(50) =null,          
	@PurchaseStart datetime,          
	@PuchaseEnd datetime,          
	@TravelDateStart datetime,          
	@TravelDateEnd datetime,          
	@MinimumNightStayRequirement varchar(50) =null,          
	@MinimumSpendRequirement varchar(50) =null,          
	@PromoCodeApplied varchar(20) =null,          
	@IsTravelAirCarHotelEligible bit =null,          
	@IsAirHoteEligible bit =0,          
	@IsHotelOnlyEligible bit=0,          
	@IsAllActivtyEligible bit=0,          
	@IsTravelToMexicoEligible bit=0,          
	@IsTravelToCaribbeanEligible bit=0,          
	@IsTravelToEuropeEligible bit=0,          
	@IsTravelToSouthAmericaEligible bit=0 ,         
	@UserKey varchar(10)=0 ,  
	@CitySpecificMatchKey varchar(10)=0,
	@TripGuidKey uniqueidentifier,
        @PromotionDiscount float
AS
BEGIN
    -- Insert statements for procedure here          
	 INSERT INTO [Trip].[dbo].[TripPromotionHistory]          
			   ([PromoId]
			   ,[PromoCampaignName]          
			   ,[PublicCode]          
			   ,[PromoCampaignType]          
			   ,[DiscountRate]          
			   ,[UsageRestriction]          
			   ,[OfferMatchType]          
			   ,[HotelVenorMatch]          
			   ,[HotelChainMatch]          
			   ,[HotelGroupMatch]          
			   ,[CitySpecificMatch]          
			   ,[SpecificAirportCodeMatch]          
			   ,[PurchaseStart]          
			   ,[PuchaseEnd]          
			   ,[TravelDateStart]          
			   ,[TravelDateEnd]          
			   ,[MinimumNightStayRequirement]          
			   ,[MinimumSpendRequirement]          
			   ,[PromoCodeApplied]          
			   ,[IsTravelAirCarHotelEligible]          
			   ,[IsAirHoteEligible]          
			   ,[IsHotelOnlyEligible]          
			   ,[IsAllActivtyEligible]          
			   ,[IsTravelToMexicoEligible]          
			   ,[IsTravelToCaribbeanEligible]          
			   ,[IsTravelToEuropeEligible]          
			   ,[IsTravelToSouthAmericaEligible],        
			   [UserKey],        
			   [CreateDate],        
			   [ModifiedDate],  
			   [CitySpecificMatchKey],  
			   [TripGuidKey],
			   [PromotionDiscount])        
		 VALUES          
   			   (    @PromoId,
                	        @PromoCampaignName,            
				@PublicCode,          
				@PromoCampaignType,          
				@DiscountRate,          
				@UsageRestriction,          
				@OfferMatchType,          
				@HotelVenorMatch,          
				@HotelChainMatch,          
				@HotelGroupMatch,          
				@CitySpecificMatch,          
				@SpecificAirportCodeMatch,          
				CONVERT(VARCHAR(10),@PurchaseStart,101),          
				CONVERT(VARCHAR(10),@PuchaseEnd,101),              
				CONVERT(VARCHAR(10),@TravelDateStart,101),          
				CONVERT(VARCHAR(10),@TravelDateEnd,101),          
				@MinimumNightStayRequirement,          
				@MinimumSpendRequirement,          
				@PromoCodeApplied,          
				@IsTravelAirCarHotelEligible,          
				@IsAirHoteEligible,          
				@IsHotelOnlyEligible,          
				@IsAllActivtyEligible,          
				@IsTravelToMexicoEligible,          
				@IsTravelToCaribbeanEligible,          
				@IsTravelToEuropeEligible,          
				@IsTravelToSouthAmericaEligible,        
				@UserKey  ,        
				GETDATE(),        
				GETDATE(),  
				@CitySpecificMatchKey,
				@TripGuidKey,
				@PromotionDiscount
                           ) 
END
GO
