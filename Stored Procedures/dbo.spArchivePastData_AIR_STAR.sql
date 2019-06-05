SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-----------------------------------------------------------
-- Author	: Gopal N
-- Date		: 06-SEP-2011
-- Desc		: To Archive all data from AIR related tables
-----------------------------------------------------------

CREATE PROCEDURE [dbo].[spArchivePastData_AIR_STAR]
AS 
BEGIN

	DECLARE @Description VARCHAR(8000)
	DECLARE @LogArchival TABLE 
	(
		[fldModule] [varchar](100)			NULL,
		[fldDate] [datetime]				NULL,
		[fldStep] [int]						NULL,
		[fldDescription] [varchar](8000)	NULL,
		[fldRowsAffected] [int]				NULL
	)	

	BEGIN TRY
	
		BEGIN TRANSACTION

	-- INSERT INTO ARCHIVE DATABASE (TIP_REPORT) --------------------------------------------------------------------------------------
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 1, 'ARCHIVAL OF AIR Related ROWS', NULL)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 2, '1.  INSERT INTO AIRREQUEST', NULL)

			INSERT INTO TIP_Report.dbo.AirRequest
				([airRequestKey], [airRequestTypeKey], [airRequestCreated], [isInternationalTrip])
			SELECT AR.[airRequestKey], AR.[airRequestTypeKey], AR.[airRequestCreated], AR.[isInternationalTrip] 
			FROM AirRequest AR
			
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 3, '1.  INSERT INTO AIRREQUEST', @@ROWCOUNT)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 4, '2.  INSERT INTO AIRSUBREQUEST', NULL)

			INSERT INTO TIP_Report.dbo.AirSubRequest
			(	[airSubRequestKey],[airRequestKey], [airRequestDateTypeKey], [airRequestDepartureAirport], 
				[airRequestArrivalAirport], [airRequestDepartureDate], [airRequestDepartureDateVariance], 
				[airRequestArrivalDate], [airRequestArrivalDateVariance], [airRequestCalendarMonth], 
				[airRequestCalendarMinDays], [airRequestCalendarMaxDays], [airSubRequestLegIndex]
			)
			SELECT ASR.[airSubRequestKey], ASR.[airRequestKey], ASR.[airRequestDateTypeKey], 
				ASR.[airRequestDepartureAirport], ASR.[airRequestArrivalAirport], 
				ASR.[airRequestDepartureDate], ASR.[airRequestDepartureDateVariance], 
				ASR.[airRequestArrivalDate], ASR.[airRequestArrivalDateVariance], 
				ASR.[airRequestCalendarMonth], ASR.[airRequestCalendarMinDays], 
				ASR.[airRequestCalendarMaxDays], ASR.[airSubRequestLegIndex] 
			FROM AirSubRequest ASR
			
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 5, '2.  INSERT INTO AIRSUBREQUEST', @@ROWCOUNT)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 6, '3.  INSERT INTO AIRRESPONSE', NULL)
					
			INSERT INTO TIP_Report.dbo.airResponse
			(
				[airResponseKey], [airSubRequestKey], [airPriceBase], [airPriceTax], [gdsSourceKey], [refundable],
				[airClass], [priceClassCommentsSuperSaver], [priceClassCommentsEconSaver],
				[priceClassCommentsFirstFlex], [priceClassCommentsCorporate], [priceClassCommentsEconFlex],
				[priceClassCommentsEconUpgrade], [airSuperSaverPrice], [airEconSaverPrice], 
				[airFirstFlexPrice], [airCorporatePrice], [airEconFlexPrice], [airEconUpgradePrice], 
				[airClassSuperSaver], [airClassEconSaver], [airClassFirstFlex], [airClassCorporate], 
				[airClassEconFlex], [airClassEconUpgrade], [airSuperSaverSeatRemaining], [airEconSaverSeatRemaining], 
				[airFirstFlexSeatRemaining], [airCorporateSeatRemaining], [airEconFlexSeatRemaining], 
				[airEconUpgradeSeatRemaining], [airSuperSaverFareReferenceKey], [airEconSaverFareReferenceKey], 
				[airFirstFlexFareReferenceKey], [airCorporateFareReferenceKey], [airEconFlexFareReferenceKey], 
				[airEconUpgradeFareReferenceKey], [airPriceClassSelected], [airSuperSaverTax], [airEconSaverTax], 
				[airEconFlexTax], [airCorporateTax], [airEconUpgradetax], [airFirstFlexTax], 
				[airSuperSaverFareBasisCode], [airEconSaverFareBasisCode], [airFirstFlexFareBasisCode], 
				[airCorporateFareBasisCode], [airEconFlexFareBasisCode], [airEconUpgradeFareBasisCode],
				[isBrandedFare], [cabinClass]
			)
			SELECT ARS.[airResponseKey], ARS.[airSubRequestKey], ARS.[airPriceBase], ARS.[airPriceTax], ARS.[gdsSourceKey], ARS.[refundable],
				ARS.[airClass], ARS.[priceClassCommentsSuperSaver], ARS.[priceClassCommentsEconSaver],
				ARS.[priceClassCommentsFirstFlex], ARS.[priceClassCommentsCorporate], ARS.[priceClassCommentsEconFlex],
				ARS.[priceClassCommentsEconUpgrade], ARS.[airSuperSaverPrice], ARS.[airEconSaverPrice], 
				ARS.[airFirstFlexPrice], ARS.[airCorporatePrice], ARS.[airEconFlexPrice], ARS.[airEconUpgradePrice], 
				ARS.[airClassSuperSaver], ARS.[airClassEconSaver], ARS.[airClassFirstFlex], ARS.[airClassCorporate], 
				ARS.[airClassEconFlex], ARS.[airClassEconUpgrade], ARS.[airSuperSaverSeatRemaining], ARS.[airEconSaverSeatRemaining], 
				ARS.[airFirstFlexSeatRemaining], ARS.[airCorporateSeatRemaining], ARS.[airEconFlexSeatRemaining], 
				ARS.[airEconUpgradeSeatRemaining], ARS.[airSuperSaverFareReferenceKey], ARS.[airEconSaverFareReferenceKey], 
				ARS.[airFirstFlexFareReferenceKey], ARS.[airCorporateFareReferenceKey], ARS.[airEconFlexFareReferenceKey], 
				ARS.[airEconUpgradeFareReferenceKey], ARS.[airPriceClassSelected], ARS.[airSuperSaverTax], ARS.[airEconSaverTax], 
				ARS.[airEconFlexTax], ARS.[airCorporateTax], ARS.[airEconUpgradetax], ARS.[airFirstFlexTax], 
				ARS.[airSuperSaverFareBasisCode], ARS.[airEconSaverFareBasisCode], ARS.[airFirstFlexFareBasisCode], 
				ARS.[airCorporateFareBasisCode], ARS.[airEconFlexFareBasisCode], ARS.[airEconUpgradeFareBasisCode],
				ARS.[isBrandedFare], ARS.[cabinClass]
			FROM AirResponse ARS
				INNER JOIN AirSubRequest ASR ON ARS.airSubRequestKey = ASR.airSubRequestKey
				INNER JOIN AirRequest AR ON ASR.airRequestKey = AR.airRequestKey

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 7, '3.  INSERT INTO AIRRESPONSE', @@ROWCOUNT)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 8, '4.  INSERT INTO AIRSEGMENTS', NULL)
				
			INSERT INTO TIP_Report.dbo.AirSegments
			(
				[airSegmentKey], [airResponseKey], [airLegNumber], [airSegmentMarketingAirlineCode], 
				[airSegmentOperatingAirlineCode], [airSegmentFlightNumber], [airSegmentDuration], 
				[airSegmentEquipment], [airSegmentMiles], [airSegmentDepartureDate], [airSegmentArrivalDate], 
				[airSegmentDepartureAirport], [airSegmentArrivalAirport], [airSegmentResBookDesigCode], 
				[airSegmentDepartureOffset], [airSegmentArrivalOffset], [airSegmentSeatRemaining], 
				[airSegmentMarriageGrp], [airFareBasisCode], [airFareReferenceKey],
				[airSegmentOperatingFlightNumber], [airsegmentCabin]
			)
			SELECT ASG.[airSegmentKey], ASG.[airResponseKey], ASG.[airLegNumber], ASG.[airSegmentMarketingAirlineCode], 
				ASG.[airSegmentOperatingAirlineCode], ASG.[airSegmentFlightNumber], ASG.[airSegmentDuration], 
				ASG.[airSegmentEquipment], ASG.[airSegmentMiles], ASG.[airSegmentDepartureDate], 
				ASG.[airSegmentArrivalDate], ASG.[airSegmentDepartureAirport], ASG.[airSegmentArrivalAirport], 
				ASG.[airSegmentResBookDesigCode], ASG.[airSegmentDepartureOffset], ASG.[airSegmentArrivalOffset], 
				ASG.[airSegmentSeatRemaining], ASG.[airSegmentMarriageGrp], ASG.[airFareBasisCode], 
				ASG.[airFareReferenceKey],
				ASG.[airSegmentOperatingFlightNumber], ASG.[airsegmentCabin]
			FROM AirSegments ASG
				INNER JOIN AirResponse ARS ON ASG.airResponseKey = ARS.airResponseKey
				INNER JOIN AirSubRequest ASR ON ARS.airSubRequestKey = ASR.airSubRequestKey
				INNER JOIN AirRequest AR ON ASR.airRequestKey = AR.airRequestKey

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 9, '4.  INSERT INTO AIRSEGMENTS', @@ROWCOUNT)

	-- INSERT INTO ARCHIVE DATABASE (TIP_REPORT) COMPLETED ------------------------------------------------------------------------------

	-- DELETE ARCHIVED DATA FROM ORIGINAL TABLES ----------------------------------------------------------------------------------------

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 10, '5.  DELETING FROM AIRSEGMENTS', NULL)

			DELETE FROM AirSegments 
			
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 11, '6.  DELETING FROM AIRSEGMENTS', @@ROWCOUNT)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 12, '7.  DELETING FROM AIRRESPONSE', NULL)
						
			DELETE FROM AirResponse 
			
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 13, '8.  DELETING FROM AIRRESPONSE', @@ROWCOUNT)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 14, '9.  DELETING FROM AIRSUBREQUEST', NULL)
			
			DELETE FROM AirSubRequest 
			
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 15, '10.  DELETING FROM AIRSUBREQUEST', @@ROWCOUNT)

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 16, '11.  DELETING FROM AIRREQUEST', NULL)
			
			DELETE FROM AirRequest 

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 17, '12.  DELETING FROM AIRREQUEST', @@ROWCOUNT)
				
	-- DELETE ARCHIVED DATA FROM ORIGINAL TABLES COMPLETED ----------------------------------------------------------------------------------------

		COMMIT TRANSACTION

	END TRY
	BEGIN CATCH
		
		SET @Description = 'Error Occured >> Error_Number: ' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ' : Error at Line : ' + CONVERT(VARCHAR(100), ERROR_LINE()) + ' ::: Error Description : ' + ERROR_MESSAGE()
		INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected) 
			VALUES ('AIR', GETDATE(), -1, @Description, NULL)

		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
			
	END CATCH

	INSERT INTO [Log].dbo.LogArchival
	SELECT * FROM @LogArchival


END
GO
