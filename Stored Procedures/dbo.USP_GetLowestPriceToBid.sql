SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 24th May 2012
-- Description:	Compares the lowest price for the current date with the booked date and insert the data in table
-- =============================================
--Exec USP_GetLowestPriceToBid 29314,22
CREATE PROCEDURE [dbo].[USP_GetLowestPriceToBid]
	-- Add the parameters for the stored procedure here
	@AirSubRequestKey INT
	,@PkGroupId INT
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;    
	
	--Declare @MinCurrentPrice float
			--,@MinPriceCount int
			
	Declare @TblGroup as table
	(	
		PkId int, PkGroupId int, TripRequestKey int, TripKey int, AirRequestKey int,AirRequestTypeKey int,BookedPrice Float,PassengerEmailID varchar(100)
		,AirResponseKey1 Varchar(100),CurrentPrice1 Float,AirResponseKey2 Varchar(100),CurrentPrice2 Float,AirResponseKey3 Varchar(100),CurrentPrice3 Float
	)
	Declare @TblBookedInfo as table(TripKey int,BookedPrice Float,PassengerEmailID VARCHAR(100))
	Declare @TblMinCurrentPrice as Table(PkId int identity(1,1),AirResponseKey Varchar(100),CurrentMinimumPrice float)
	
	Insert into @TblGroup(PkId,PkGroupId,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey)
	Select PkId,PkGroupId,TripRequestKey,TripKey,AirRequestKey,AirRequestTypeKey from AirRequestForBid where PkGroupId = @PkGroupId
	
	Insert into @TblBookedInfo
	SELECT TRA.tripKey,(TRA.searchAirPrice + TRA.searchAirTax) As BookingPrice, TI.PassengerEmailID 
	FROM TripAirResponse TRA
	Inner Join TripPassengerInfo TI on TRA.tripKey = Ti.TripKey
	WHERE TRA.tripKey in (Select TripKey from @TblGroup) and TI.Active = 1
 
	 
	 UPdate TG Set BookedPrice = TBI.BookedPrice
	 ,PassengerEmailID = TBI.PassengerEmailID
	 From  @TblGroup TG inner join @TblBookedInfo TBI on TG.TripKey = TBI.TripKey 
		
	Insert into @TblMinCurrentPrice (AirResponseKey,CurrentMinimumPrice)	
	SELECT TOP 3 airResponseKey, MIN(airPriceBase + airPriceTax) AS Price
	FROM AirResponse WHERE airSubRequestKey = @AirSubRequestKey
	GROUP BY airResponseKey
	
	--Set @MinPriceCount = (select COUNT(*) from @TblMinCurrentPrice)
	
	Update @TblGroup Set AirResponseKey1 = (Select AirResponseKey from @TblMinCurrentPrice where PkId = 1)
		   ,CurrentPrice1 = (Select CurrentMinimumPrice from @TblMinCurrentPrice where PkId = 1)
		   ,AirResponseKey2 = (Select AirResponseKey from @TblMinCurrentPrice where PkId = 2)
		   ,CurrentPrice2 = (Select CurrentMinimumPrice from @TblMinCurrentPrice where PkId = 2)
		   ,AirResponseKey3 = (Select AirResponseKey from @TblMinCurrentPrice where PkId = 3)
		   ,CurrentPrice3 = (Select CurrentMinimumPrice from @TblMinCurrentPrice where PkId = 3)
	
	--select * from @TblMinCurrentPrice
		
	--Set @MinCurrentPrice = (SELECT TOP 1 MIN(airPriceBase + airPriceTax) AS Price FROM AirResponse WHERE airSubRequestKey = @AirSubRequestKey)
	
	--select @MinCurrentPrice
	
	Insert into BidPriceMaster(TripKey,AirRequestTypeKey,BookedPrice,EmailId,AirResponseKey1,CurrentPrice1,AirResponseKey2,CurrentPrice2,AirResponseKey3,CurrentPrice3)
	select TripKey,AirRequestTypeKey,BookedPrice,PassengerEmailID,AirResponseKey1,CurrentPrice1,AirResponseKey2,CurrentPrice2,AirResponseKey3,CurrentPrice3 
	from @TblGroup where (ISNULL(BookedPrice,0) > ISNULL((Select MIN(CurrentMinimumPrice) From @TblMinCurrentPrice),0))--(ISNULL(@MinCurrentPrice,0) < ISNULL(BookedPrice,0))
	
END




GO
