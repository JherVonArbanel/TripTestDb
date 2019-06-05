SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_InsertHotelCacheData] 
(	
@Origin varchar(5),
@Month varchar(15),
@CacheData nvarchar(max),
@FilteredCacheData nvarchar(max),
@LowestPriceCacheData nvarchar(max),
@LowestPrice float,
@Savings float
)
AS
BEGIN
	IF EXISTS(select 1 from HotelCacheData where (Origin = @Origin AND [MONTH] LIKE @Month))
		BEGIN
			UPDATE HotelCacheData
			SET CacheData = @CacheData,FilteredCacheData = @FilteredCacheData,CreatedDate = GETDATE(),[Month]= @Month,LowestPriceCacheData=@LowestPriceCacheData, LowestPrice=@LowestPrice , AvgSaving= @Savings
			WHERE Origin = @Origin AND [MONTH] LIKE @Month
		END
	ELSE	 
		BEGIN
			INSERT INTO HotelCacheData(Origin,CreatedDate,CacheData,FilteredCacheData,[Month],[LowestPriceCacheData],[LowestPrice],[AvgSaving]) VALUES(@Origin,GETDATE(),@CacheData,@FilteredCacheData, @Month,@LowestPriceCacheData,@LowestPrice,@Savings);
		END
END
GO
