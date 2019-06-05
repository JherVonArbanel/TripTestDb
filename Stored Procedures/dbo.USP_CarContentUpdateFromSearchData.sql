SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 05-05-2015
-- Description:	CarContent db update from search call data
-- =============================================
CREATE PROCEDURE [dbo].[USP_CarContentUpdateFromSearchData]
AS
BEGIN

	CREATE TABLE #tmpCarRequest(
	[carRequestKey] [int]  NOT NULL,
	[pickupCityCode] [varchar](50) NOT NULL,
	[dropoffCityCode] [varchar](3) NOT NULL,
	[pickupDate] [datetime] NOT NULL,
	[dropoffDate] [datetime] NOT NULL,
	[carRequestCreated] [datetime] NOT NULL,
	[NoofCars] [int] NULL,
	[isCacheDataCollected] [bit] NOT NULL
	)


	INSERT INTO #tmpCarRequest
	SELECT * FROM [Trip].[dbo].[CarRequest] WHERE pickupDate > GETDATE() and isCacheDataCollected=0
	order by 1 desc

	DECLARE @carRequestKey int, @cityCode varchar(50)
	DECLARE @carResponseKey uniqueidentifier, @vendorCode varchar(10)
	DECLARE @carCategoryCode varchar(10), @isExit int

	SET @isExit =0

	DECLARE carRequest_cursor CURSOR FOR 
		SELECT  [carRequestKey],[pickupCityCode]
		FROM #tmpCarRequest  


	OPEN carRequest_cursor

	FETCH NEXT FROM carRequest_cursor 
	INTO @carRequestKey, @cityCode

	WHILE @@FETCH_STATUS = 0 --and @isExit=0
	BEGIN

		DECLARE carResponse_cursor CURSOR FOR 
		SELECT  [carResponseKey], [carVendorKey]
		FROM dbo.CarResponse  WHERE carRequestKey = @carRequestKey 

		OPEN carResponse_cursor

		FETCH NEXT FROM carResponse_cursor 
		INTO @carResponseKey, @vendorCode

		WHILE @@FETCH_STATUS = 0 
		BEGIN

			--  Select * from CarResponse where carRequestKey=@carRequestKey
			--Select * from CarResponseDetail where carResponseKey = @carResponseKey
			--Select carCategoryCode from CarResponseDetail where carResponseKey = @carResponseKey
			--Select * from CarContent..SabreVehicles where LocationAirportCode=@cityCode and VendorCode = @vendorCode

			--Sabre Locations Update 
			IF Not Exists (SELECT top 1 * from CarContent..SabreLocations 
				WHERE LocationAirportCode=@cityCode and LocationCategoryCode=@cityCode and VendorCode = @vendorCode)
			BEGIN
			
				INSERT INTO CarContent..SabreLocations
				SELECT top 1       
				@vendorCode
				,[LocationAirportCode]
				,[LocationCategoryCode]
				,[LocationName]
				,[LocationAddress1]
				,[LocationCity]
				,[Locationstate]
				,[LocationCountry]
				,[Latitude]
				,[Longitude]
				,[ZipCode]
				,[Distance]
				,[DistanceUnit]
				,[isCacheCreated] =1
				From CarContent..SabreLocations WHERE LocationAirportCode=@cityCode and LocationCategoryCode=@cityCode

			END


			SET @carCategoryCode = null
			--Sabre Vehicles Update
			--Select @carCategoryCode = carCategoryCode from CarResponseDetail where carResponseKey = @carResponseKey and carCategoryCode not in (Select SippCode from CarContent..SabreVehicles WHERE LocationAirportCode=@cityCode and VendorCode = @vendorCode)

			DECLARE carResponseDetail_cursor CURSOR FOR 
			Select carCategoryCode from CarResponseDetail where carResponseKey = @carResponseKey and carCategoryCode not in (Select SippCode from CarContent..SabreVehicles WHERE LocationAirportCode=@cityCode and VendorCode = @vendorCode)

			OPEN carResponseDetail_cursor

			FETCH NEXT FROM carResponseDetail_cursor 
			INTO @carCategoryCode

			WHILE @@FETCH_STATUS = 0 
			BEGIN

				INSERT INTO [CarContent].[dbo].[SabreVehicles]
				SELECT Top 1 
				@vendorCode
				,@cityCode
				,@cityCode
				,[VehicleName]
				,[MakeClassGroup]
				,[SippCode]
				,[PsgrCapacity]
				,[Baggage]
				,[Doors]
				,[ImageName]
				,[IsMissingURL]
				,[NewImageName]
				,[isCacheCreated]=1
				FROM [CarContent].[dbo].[SabreVehicles] where SippCode=@carCategoryCode and LocationAirportCode=@cityCode

				--SET @isExit= 1

				FETCH NEXT FROM carResponseDetail_cursor 
				INTO @carCategoryCode
			END   

			CLOSE carResponseDetail_cursor
			DEALLOCATE carResponseDetail_cursor

			UPDATE [Trip]..[CarRequest] SET isCacheDataCollected=1 WHERE carRequestKey=@carRequestKey

			FETCH NEXT FROM carResponse_cursor 
			INTO @carResponseKey,@vendorCode
		END   

		CLOSE carResponse_cursor
		DEALLOCATE carResponse_cursor

		FETCH NEXT FROM carRequest_cursor 
		INTO @carRequestKey, @cityCode
	END

	CLOSE carRequest_cursor
	DEALLOCATE carRequest_cursor

	drop table #tmpCarRequest
END
GO
