SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 18th Jan 2013
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripSavedDealHotelRadius]
	@HotelRequestKey Int
	,@OriginalHotelID Int
	,@RadiusMiles Float
	,@Rating Float
	,@HotelDailyPrice Float
	,@ThresholdPricePerDay Float
	,@StarRatingStep1_1 Float
	,@StarRatingStep1_2 Float
	,@PriceCap Float
	,@StarRatingStep2_1 Float
	,@SupplierHotelID Varchar(10)
	,@Case varchar(20)
AS
BEGIN
	
	SET NOCOUNT ON;
	
	--BEGIN TRY
	
	Declare @NeighbourhoodHotelID As Table (HotelID Varchar(50))
	Declare @TblMinThreshHoldPrice As Table(CurrentMinimumPrice float,HotelResponseKey Uniqueidentifier
	,FareCategory varchar(30),MinRate Float,Remarks Varchar(2000), HotelId varchar(30))
	
	Declare @Latitude Float
			,@Longitude Float
	
	If(@Case = 'NEIGHBOURHOOD')
	Begin
		
		Select @Latitude = Latitude, @Longitude = Longitude From HotelContent.dbo.Hotels With (NoLock) Where HotelId = @OriginalHotelID
					
		Insert Into @NeighbourhoodHotelID
		Select HotelID From TmpHotelResponse HR With (NoLock)
		Where HotelContent.dbo.fnGetDistance(@Latitude, @Longitude, HR.Latitude, HR.Longitude, 'Miles') <= @RadiusMiles
		And HotelRequestKey = @HotelRequestKey
		
		If((Select COUNT(HotelID) From @NeighbourhoodHotelID) > 0)
		Begin
			Insert Into @TblMinThreshHoldPrice (CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId)
			Select minRate,HotelResponseKey,FareCategory,minRate
			,'Miles : ' + CONVERT(Varchar,@RadiusMiles) + '. Thresh Hold Success. The per day price difference is greater than 10$. ' 
			,HotelId
			From TmpHotelResponse With (NoLock) Where HotelId IN (Select HotelID from @NeighbourhoodHotelID) 
			And (Rating >= @Rating) And ((@HotelDailyPrice - minRate) 
			>= (@ThresholdPricePerDay)) And HotelRequestKey = @HotelRequestKey
			
			If((Select COUNT(*) From @TblMinThreshHoldPrice) = 0)
			Begin
				/*Select a hotel that has (0.5 to 1) higher star rating than the original hotel, but has same rate*/
				Insert Into @TblMinThreshHoldPrice (CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId)
				Select minRate,HotelResponseKey,FareCategory,minRate
				,'Miles : ' + CONVERT(Varchar,@RadiusMiles) + '. Thresh Hold Fails. Offers found are (0.5 to 1) higher star having same price as original.'  
				,HotelId
				From TmpHotelResponse With (NoLock) Where HotelId IN (Select HotelID from @NeighbourhoodHotelID)
				And Rating between (@Rating + @StarRatingStep1_1) And (@Rating + @StarRatingStep1_2) 
				And minRate <= @HotelDailyPrice And HotelRequestKey = @HotelRequestKey
				
				If((Select COUNT(*) From @TblMinThreshHoldPrice) = 0)
				Begin /*Hotel having (1.5+) higher star rating than the original hotel, and is no more than 15$ higher per night*/
					Insert Into @TblMinThreshHoldPrice (CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId)
					Select minRate,HotelResponseKey,FareCategory,MinRate
					,'Miles : ' + CONVERT(Varchar,@RadiusMiles) + '. Thresh Hold Fails. Hotels found having (1.5+) higher star rating than the original hotel, and is no more than 15$ higher per night.' 
					,HotelId
					From TmpHotelResponse With (NoLock) Where HotelId IN (Select HotelID from @NeighbourhoodHotelID)
					And (Rating >= (@Rating + @StarRatingStep2_1)) And minRate <= (@HotelDailyPrice + @PriceCap)
					And HotelRequestKey = @HotelRequestKey
					--Set @Remarks = @Remarks + 'Thresh Hold Fails. Hotels found having (1.5+) higher star rating than the original hotel, and is no more than 15$ higher per night. '
				End/*END Select COUNT(*) From @TblMiscellaneous > 0*/
				
			End /*End Select COUNT(*) From @TblMinThreshHoldPrice > 0*/
		End
    End
    Else IF(@Case = 'DEFAULT')
    BEGIN
		Insert Into @TblMinThreshHoldPrice (CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId)
		Select minRate,HotelResponseKey,FareCategory,minRate
		,'All Conditions Fail. Inserting the original hotel from current search.' 
		,HotelId
		From TmpHotelResponse With (NoLock) Where SupplierHotelKey = @SupplierHotelID
		And HotelRequestKey = @HotelRequestKey
    END
    
    --Select CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,HotelId 
    --From @TblMinThreshHoldPrice
    

	SELECT A.CurrentMinimumPrice,HotelResponseKey,FareCategory,MinRate,Remarks,A.HotelId  
	FROM @TblMinThreshHoldPrice A
		INNER JOIN	
		(
			SELECT MIN(CurrentMinimumPrice) CurrentMinimumPrice, HotelId From @TblMinThreshHoldPrice Group By HotelId
		) B ON A.HotelId = B.HotelId AND A.CurrentMinimumPrice = B.CurrentMinimumPrice 
			
    
 --   END TRY
 --   BEGIN CATCH
	--	DECLARE @ErrorMessage NVARCHAR(4000);
	--		SET @ErrorMessage = ERROR_MESSAGE();
	--		--RAISERROR (@ErrorMessage, 16, 1);
	--		INSERT INTO TripSavedDealLog (ErrorMessage, ErrorStack) Values ('Error in stored procedure USP_GetTripSavedDealHotelRadius.', @ErrorMessage)
	--END CATCH;
    
END
GO
