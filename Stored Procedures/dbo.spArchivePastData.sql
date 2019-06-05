SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---------------------------------------------
-- Author	: Gopal N
-- Date		: 07-JUN-2011
-- Desc		: To Archive Past requested data 
---------------------------------------------

CREATE PROCEDURE [dbo].[spArchivePastData]
AS 
BEGIN

	DECLARE @Description VARCHAR(8000)

	BEGIN TRY
		BEGIN TRANSACTION
		
			TRUNCATE TABLE [Log].dbo.[LogArchival]
			
			TRUNCATE TABLE [TIP_Report].dbo.TripRequest_air
			TRUNCATE TABLE [TIP_Report].dbo.TripRequest_car
			TRUNCATE TABLE [TIP_Report].dbo.TripRequest_hotel
			TRUNCATE TABLE [TIP_Report].dbo.TripRequest
			
			
			INSERT INTO [TIP_Report].dbo.TripRequest ([tripRequestKey], [userKey], [tripTypeKey], [tripRequestCreated])
			SELECT [tripRequestKey], [userKey], [tripTypeKey], [tripRequestCreated] FROM TripRequest
			
			INSERT INTO TIP_Report.dbo.TripRequest_air
			(
				[tripRequestKey], [airRequestKey], [airRequestClassKey], [airRequestIsNonStop],
				[airRequestAdults], [airRequestSeniors], [airRequestChildren], [airRequestDepartureAirportAlternate],
				[airRequestArrivalAirportAlternate], [airRequestRefundable]
			)
			SELECT
				[tripRequestKey], [airRequestKey], [airRequestClassKey], [airRequestIsNonStop],
				[airRequestAdults], [airRequestSeniors], [airRequestChildren], [airRequestDepartureAirportAlternate],
				[airRequestArrivalAirportAlternate], [airRequestRefundable]
			FROM TripRequest_air
			
			INSERT INTO TIP_Report.dbo.TripRequest_car([tripRequestKey], [carRequestKey], [carClass])
			SELECT [tripRequestKey], [carRequestKey], [carClass] FROM TripRequest_car
			
			INSERT INTO TIP_Report.dbo.TripRequest_hotel ([tripRequestKey], [hotelRequestKey], [noOfGuests])
			SELECT [tripRequestKey], [hotelRequestKey], [noOfGuests] FROM TripRequest_hotel
			
		COMMIT TRANSACTION

		EXEC [spArchivePastData_AIR]
		EXEC [spArchivePastData_CAR]
		EXEC [spArchivePastData_HOTEL]
		
	END TRY
	BEGIN CATCH

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		SET @Description = 'Error Occured >> Error_Number: ' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ' : Error at Line : ' + CONVERT(VARCHAR(100), ERROR_LINE()) + ' ::: Error Description : ' + ERROR_MESSAGE()
		INSERT INTO [Log].dbo.LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected) 
			VALUES ('[spArchivePastData]', GETDATE(), -1, @Description, NULL)
	
	END CATCH
		
-- SELECT * FROM [Log].dbo.[LogArchival]

END
GO
