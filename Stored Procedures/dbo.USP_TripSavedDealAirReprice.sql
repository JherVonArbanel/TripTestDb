SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 27th Aug 2012
-- Description:	Insert reprice cost in TripAirPrices and update the tripAirPriceKey in TripAirResponse
-- =============================================
--exec USP_TripSavedDealAirReprice 1547,24.2,0,0,0,0,1253,24.2,118,19.7,53395,51203
CREATE PROCEDURE [dbo].[USP_TripSavedDealAirReprice] 
	@tripAdultBase   Float
	,@tripAdultTax   Float
	,@tripSeniorBase Float
	,@tripSeniorTax  Float
	,@tripYouthBase  Float
	,@tripYouthTax   Float
	,@tripChildBase  Float
	,@tripChildTax   Float
	,@tripInfantBase Float
	,@tripInfantTax  Float
	,@tripAirResponseKey Int
	,@tripAirPriceKey Int
	,@tripkey INT = 0
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @originalTripAdultBase   Float
			,@originalTripAdultTax   Float
			,@originalTripSeniorBase Float
			,@originalTripSeniorTax  Float
			,@originalTripYouthBase  Float
			,@originalTripYouthTax   Float
			,@originalTripChildBase  Float
			,@originalTripChildTax   Float
			,@originalTripInfantBase Float
			,@originalTripInfantTax  Float
			
			,@repriceTripChildBase   Float
			,@repriceTripChildTax    Float
			,@repriceTripInfantBase  Float
			,@repriceTripInfantTax   Float
			
   
	Select  @originalTripAdultBase = ISNULL(tripAdultBase,0)
			,@originalTripAdultTax = ISNULL(tripAdultTax,0) 
			,@originalTripSeniorBase = ISNULL(tripSeniorBase,0)
			,@originalTripSeniorTax = ISNULL(tripSeniorTax,0)
			,@originalTripChildBase = ISNULL(tripChildBase,0) 
			,@originalTripChildTax = ISNULL(tripChildTax,0)  
			,@originalTripInfantBase = ISNULL(tripInfantBase,0)
			,@originalTripInfantTax = ISNULL(tripInfantTax,0)
	From TripAirPrices Where tripAirPriceKey = @tripAirPriceKey
	
	--PRICE FOR ADULT, SENIOR AND YOUTH
	IF (@originalTripAdultBase = 0)
	BEGIN
		SET @originalTripAdultBase = @originalTripSeniorBase
		SET @originalTripAdultTax = @originalTripSeniorTax	
	END
	
	--PRICE FOR CHILD
	IF(@originalTripChildBase > 0)
	BEGIN
		SET @repriceTripChildBase = @originalTripChildBase
		SET @repriceTripChildTax = @originalTripChildTax
	END
	ELSE
	BEGIN
		SET @repriceTripChildBase = @originalTripAdultBase
		SET @repriceTripChildTax = @originalTripAdultTax
	END	
	
	--PRICE FOR INFANT	
	IF(@originalTripInfantBase > 0)
	BEGIN
		SET @repriceTripInfantBase = @originalTripInfantBase
		SET @repriceTripInfantTax = @originalTripInfantTax
	END
	ELSE
	BEGIN
		SET @repriceTripInfantBase = 0
		SET @repriceTripInfantTax = 0
	END
		
	UPDATE TripAirPrices 
	SET tripAdultBase = @originalTripAdultBase,tripAdultTax = @originalTripAdultTax
	,tripSeniorBase = @originalTripAdultBase,tripSeniorTax = @originalTripAdultTax
	,tripYouthBase = @originalTripAdultBase,tripYouthTax = @originalTripAdultTax
	,tripChildBase = @repriceTripChildBase,tripChildTax = @repriceTripChildTax
	,tripInfantBase = @repriceTripInfantBase,tripInfantTax = @repriceTripInfantTax
	,tripInfantWithSeatBase = 0,tripInfantWithSeatTax = 0
	WHERE tripAirPriceKey = @tripAirPriceKey
	
	DECLARE @TRIPPURCHASEDKEY AS UNIQUEIDENTIFIER  
	SELECT @TRIPPURCHASEDKEY= tripPurchasedKey FROM TRIP..Trip WHERE TRIPKEY =@TRIPKEY
	IF(@tripkey > 0 AND @TRIPPURCHASEDKEY IS NULL)
	BEGIN

	DECLARE @searchAirPrice as decimal ( 18,2)     
	DECLARE @searchAirTax as decimal ( 18,2)      
	DECLARE @noOfTraveller as INT
	DECLARE @airResponsekey AS UNIQUEIDENTIFIER   
	SELECT      
	@searchAirPrice =(( isnull(tripAdultBase,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildBase,0)*isnull(t.tripChildCount,0) ) +     
	( isnull(tripSeniorBase,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthBase,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfantBase,0)*isnull(t.tripInfantCount,0) )  + (isnull(tripInfantwithSeatBase,0)*isnull(t.tripInfantwithSeatCount,0) )  )    
	,@searchAirTax =(( isnull(tripAdulttax,0) * isnull(T.tripAdultsCount,0) ) + (isnull(tripChildtax,0)*isnull(t.tripChildCount,0) ) +     
	( isnull(tripSeniortax,0) * isnull(T.tripSeniorsCount,0) ) + (isnull(tripYouthtax,0)*isnull(t.tripYouthCount,0) ) + (isnull(tripInfanttax,0)*isnull(t.tripInfantCount,0) )+ (isnull(tripInfantwithSeattax,0)*isnull(t.tripInfantwithSeatCount,0) )  )  ,  
	@airResponsekey = Tr.airResponseKey  ,
	@noOfTraveller = T.noOfTotalTraveler
	from TripAirPrices TAP WITH(NOLOCK)       
	inner join TripAirResponse TR WITH(NOLOCK) on TAP.tripAirPriceKey =   TR.searchAirPriceBreakupKey      
	inner join Trip T WITH(NOLOCK) on TR.tripGUIDKey =(T.tripSavedKey)      
	where t.tripKey = @tripkey

	IF(@searchAirPrice > 0)
	BEGIN
		UPDATE Trip..TripDetails
		SET originalPerPersonPriceAir = ((@searchAirPrice + @searchAirTax)/ @noOfTraveller), originalTotalPriceAir = (@searchAirPrice + @searchAirTax)
		WHERE tripKey = @tripkey
	END
		
	
	END
	
	
END
GO
