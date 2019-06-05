SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---------------------------------------------------------------------------
-- Author	: Gopal N
-- Date		: 27-JAN-2011
-- Desc		: To Archive Past requested data from HOTEL related tables
---------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[spArchivePastData_HOTEL]
AS 
BEGIN

	DECLARE @TodaysDate				DATE
	DECLARE @Description			VARCHAR(8000)
	DECLARE @hotelNOTEXIST			TABLE(hotelRequestKey INT)
	DECLARE @LogArchival			TABLE 
	(
		[fldModule]			[varchar](100)	NULL,
		[fldDate]			[datetime]		NULL,
		[fldStep]			[int]			NULL,
		[fldDescription]	[varchar](8000) NULL,
		[fldRowsAffected]	[int]			NULL
	)	
	
	SET @TodaysDate = CONVERT(DATE, GETDATE(), 103)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('HOTEL', GETDATE(), 1, '1.  INSERT INTO @hotelNOTEXIST', NULL)

	INSERT INTO @hotelNOTEXIST
	SELECT hotelRequestKey FROM HotelRequest WHERE CONVERT(DATE, HotelRequest.checkOutDate, 103) < @TodaysDate

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('HOTEL', GETDATE(), 2, '2.  INSERT INTO @hotelNOTEXIST', @@ROWCOUNT)
		
	BEGIN TRY
		
		BEGIN TRANSACTION

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 3, 'ARCHIVAL OF ACTUAL PAST DATED ROWS', NULL)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 4, '1.  INSERT INTO HOTELREQUEST', NULL)
			
		----  INSERT INTO ARCHIVE DATABASE --------------
			INSERT INTO TIP_Report.dbo.HotelRequest
				(hotelRequestKey, hotelCityCode, checkInDate, checkOutDate, hotelRequestCreated, hotelAddress, NoOfRooms)
			SELECT HR.hotelRequestKey, HR.hotelCityCode, HR.checkInDate, HR.checkOutDate, HR.hotelRequestCreated,
				HR.hotelAddress, HR.NoOfRooms 
			FROM HotelRequest HR
				INNER JOIN @hotelNOTEXIST tmp ON HR.hotelRequestKey = tmp.hotelRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 5, '2.  INSERT INTO HOTELREQUEST', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 6, '3.  INSERT INTO HOTELRESPONSE', NULL)
						
			INSERT INTO TIP_Report.dbo.HotelResponse
			(	
				hotelResponseKey, hotelRequestKey, supplierHotelKey, supplierId, minRate, minRateTax, hotelsComType
			)
			SELECT HRS.hotelResponseKey, HRS.hotelRequestKey, HRS.supplierHotelKey, HRS.supplierId, HRS.minRate, HRS.minRateTax,
				HRS.hotelsComType
			FROM HotelResponse HRS
				INNER JOIN @hotelNOTEXIST tmp ON HRS.hotelRequestKey = tmp.hotelRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 7, '4.  INSERT INTO HOTELRESPONSE', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 8, '5.  INSERT INTO HOTELRESPONSEDETAIL', NULL)
						
			INSERT INTO TIP_Report.dbo.HotelResponseDetail
			(
				hotelResponseDetailKey, hotelResponseKey, hotelDailyPrice, hotelDescription, supplierId, hotelRatePlanCode,
				hotelTotalPrice, hotelPriceType, hotelTaxRate, rateDescription, guaranteeCode, CancellationPolicy, hotelsComSupplierType
			)
			SELECT HRD.hotelResponseDetailKey, HRD.hotelResponseKey, HRD.hotelDailyPrice, HRD.hotelDescription, HRD.supplierId, 
				HRD.hotelRatePlanCode, HRD.hotelTotalPrice, HRD.hotelPriceType, HRD.hotelTaxRate, HRD.rateDescription, HRD.guaranteeCode,
				HRD.CancellationPolicy, HRD.hotelsComSupplierType
			FROM HotelResponseDetail HRD
				INNER JOIN HotelResponse HRS ON HRD.hotelResponseKey = HRS.hotelResponseKey
				INNER JOIN HotelRequest HR ON HRS.hotelRequestKey = HR.hotelRequestKey
				INNER JOIN @hotelNOTEXIST tmp ON HR.hotelRequestKey = tmp.hotelRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 9, '5.  INSERT INTO HOTELRESPONSEDETAIL', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 10, '6.  DELETING FROM HOTELRESPONSEDETAIL', NULL)

			DELETE HRD -- STEP 2 : Delete HotelResponseDetail Records which is related to not exist
			FROM HotelResponseDetail HRD
				INNER JOIN HotelResponse HRS ON HRD.hotelResponseKey = HRS.hotelResponseKey
				INNER JOIN HotelRequest HR ON HRS.hotelRequestKey = HR.hotelRequestKey
				INNER JOIN @hotelNOTEXIST tmp ON HR.hotelRequestKey = tmp.hotelRequestKey
			
 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 11, '7.  DELETING FROM HOTELRESPONSEDETAIL', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 12, '8.  DELETING FROM HOTELRESPONSE', NULL)
			
			DELETE HRS -- STEP 3 : Delete HotelResponse Records which is related to not exist
			FROM HotelResponse HRS
				INNER JOIN HotelRequest HR ON HRS.hotelRequestKey = HR.hotelRequestKey
				INNER JOIN @hotelNOTEXIST notExist ON HR.hotelRequestKey = notExist.hotelRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 13, '9.  DELETING FROM HOTELRESPONSE', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 14, '10.  DELETING FROM HOTELREQUEST', NULL)

			DELETE HR -- STEP 5 : Delete HotelRequest Records which is related to not exist
			FROM HotelRequest HR 
				INNER JOIN @hotelNOTEXIST notExist ON HR.hotelRequestKey = notExist.hotelRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('HOTEL', GETDATE(), 15, '11.  DELETING FROM HOTELREQUEST', @@ROWCOUNT)
						
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		
		SET @Description = 'Error Occured >> Error_Number: ' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ' : Error at Line : ' + CONVERT(VARCHAR(100), ERROR_LINE()) + ' ::: Error Description : ' + ERROR_MESSAGE()
		INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected) 
			VALUES ('HOTEL', GETDATE(), -1, @Description, NULL)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
			
	END CATCH

	INSERT INTO [Log].dbo.LogArchival
	SELECT * FROM @LogArchival

END
GO
