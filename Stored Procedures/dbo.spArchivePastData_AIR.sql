SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-----------------------------------------------------------------------------------
-- Author	: Gopal N
-- Date		: 19-JAN-2011
-- Desc		: To Archive Past requested data from AIR related tables
-----------------------------------------------------------------------------------

CREATE PROCEDURE [dbo].[spArchivePastData_AIR]
AS 
BEGIN

	DECLARE @airResNOTEXIST			TABLE(airRequestKey INT)
	DECLARE @DisconnectedSubRequest	TABLE(airSubRequestKey INT)
	DECLARE @DisconnectedRequest	TABLE(airRequestKey INT)
	DECLARE @DisconnectedResponse	TABLE(airResponseKey UNIQUEIDENTIFIER)
	DECLARE @Description			VARCHAR(8000)

	DECLARE @TodaysDate DATE
	SET		@TodaysDate = CONVERT(DATE, GETDATE(), 103)
		
	DECLARE @LogArchival TABLE 
	(
		[fldModule] [varchar](100) NULL,
		[fldDate] [datetime] NULL,
		[fldStep] [int] NULL,
		[fldDescription] [varchar](8000) NULL,
		[fldRowsAffected] [int] NULL
	)	

	INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
		VALUES ('AIR', GETDATE(), 1, '1.  INSERT INTO @RESNOTEXIST', NULL)

	INSERT INTO @airResNOTEXIST
	SELECT DISTINCT ASR.airRequestKey
	FROM AirSubRequest ASR 
		INNER JOIN 
		(
			SELECT airRequestKey, MAX(airrequestDepartureDate) airrequestDepartureDate
			FROM AirSubRequest ASR 
			GROUP BY airRequestKey	
		) A ON ASR.airRequestKey = A.airRequestKey AND CONVERT(DATE, A.airRequestDepartureDate, 103) < @TodaysDate
		LEFT OUTER JOIN AirResponse AR ON ASR.airSubRequestKey = AR.airSubRequestKey 

			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
				VALUES ('AIR', GETDATE(), 2, '2.  INSERT INTO @RESNOTEXIST', @@ROWCOUNT)


	BEGIN TRY
		
		BEGIN TRANSACTION
	
			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected) 
				VALUES ('AIR', GETDATE(), 3, 'Inside Disconnected Records', NULL)

			---------------------------- DELETE DISCONNECTED RECORDS --------------------------------------------------------------------------------
			-- DELETE those records which exist in AirResponse and not exist in AirSegments
			--INSERT INTO @DisconnectedResponse
			--SELECT airResponseKey FROM AirResponse WHERE airResponseKey NOT IN (SELECT DISTINCT airResponseKey FROM AirSegments)

			--		INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 3, 'INSERT INTO @DISCONNECTEDRESPONSE', @@ROWCOUNT)

			--		INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 4, '1.  AIR RESPONSE: >> B. INSERT INTO TIP_Report.dbo.airResponse', NULL)

			--INSERT INTO TIP_Report.dbo.airResponse
			--(
			--	[airResponseKey], [airSubRequestKey], [airPriceBase], [airPriceTax], [gdsSourceKey],
			--	[airClass], [priceClassCommentsSuperSaver], [priceClassCommentsEconSaver],
			--	[priceClassCommentsFirstFlex], [priceClassCommentsCorporate], [priceClassCommentsEconFlex],
			--	[priceClassCommentsEconUpgrade], [airSuperSaverPrice], [airEconSaverPrice], 
			--	[airFirstFlexPrice], [airCorporatePrice], [airEconFlexPrice], [airEconUpgradePrice], 
			--	[airClassSuperSaver], [airClassEconSaver], [airClassFirstFlex], [airClassCorporate], 
			--	[airClassEconFlex], [airClassEconUpgrade], [airSuperSaverSeatRemaining], [airEconSaverSeatRemaining], 
			--	[airFirstFlexSeatRemaining], [airCorporateSeatRemaining], [airEconFlexSeatRemaining], 
			--	[airEconUpgradeSeatRemaining], [airSuperSaverFareReferenceKey], [airEconSaverFareReferenceKey], 
			--	[airFirstFlexFareReferenceKey],[airCorporateFareReferenceKey], [airEconFlexFareReferenceKey], 
			--	[airEconUpgradeFareReferenceKey], [airPriceClassSelected], [airSuperSaverTax], [airEconSaverTax], 
			--	[airEconFlexTax], [airCorporateTax], [airEconUpgradetax], [airFirstFlexTax], 
			--	[airSuperSaverFareBasisCode], [airEconSaverFareBasisCode], [airFirstFlexFareBasisCode], 
			--	[airCorporateFareBasisCode], [airEconFlexFareBasisCode], [airEconUpgradeFareBasisCode]
			--)
			--SELECT ARS.[airResponseKey], ARS.[airSubRequestKey], ARS.[airPriceBase], ARS.[airPriceTax], ARS.[gdsSourceKey],
			--	ARS.[airClass], ARS.[priceClassCommentsSuperSaver], ARS.[priceClassCommentsEconSaver],
			--	ARS.[priceClassCommentsFirstFlex], ARS.[priceClassCommentsCorporate], ARS.[priceClassCommentsEconFlex],
			--	ARS.[priceClassCommentsEconUpgrade], ARS.[airSuperSaverPrice], ARS.[airEconSaverPrice], 
			--	ARS.[airFirstFlexPrice], ARS.[airCorporatePrice], ARS.[airEconFlexPrice], ARS.[airEconUpgradePrice], 
			--	ARS.[airClassSuperSaver], ARS.[airClassEconSaver], ARS.[airClassFirstFlex], ARS.[airClassCorporate], 
			--	ARS.[airClassEconFlex], ARS.[airClassEconUpgrade], ARS.[airSuperSaverSeatRemaining], ARS.[airEconSaverSeatRemaining], 
			--	ARS.[airFirstFlexSeatRemaining], ARS.[airCorporateSeatRemaining], ARS.[airEconFlexSeatRemaining], 
			--	ARS.[airEconUpgradeSeatRemaining], ARS.[airSuperSaverFareReferenceKey], ARS.[airEconSaverFareReferenceKey], 
			--	ARS.[airFirstFlexFareReferenceKey], ARS.[airCorporateFareReferenceKey], ARS.[airEconFlexFareReferenceKey], 
			--	ARS.[airEconUpgradeFareReferenceKey], ARS.[airPriceClassSelected], ARS.[airSuperSaverTax], ARS.[airEconSaverTax], 
			--	ARS.[airEconFlexTax], ARS.[airCorporateTax], ARS.[airEconUpgradetax], ARS.[airFirstFlexTax], 
			--	ARS.[airSuperSaverFareBasisCode], ARS.[airEconSaverFareBasisCode], ARS.[airFirstFlexFareBasisCode], 
			--	ARS.[airCorporateFareBasisCode], ARS.[airEconFlexFareBasisCode], ARS.[airEconUpgradeFareBasisCode] 
			--FROM AirResponse ARS
			--	INNER JOIN @DisconnectedResponse tmp ON ARS.airResponseKey = tmp.airResponseKey

			--		INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 5, '1.  AIR RESPONSE: >> B. INSERT INTO TIP_Report.dbo.airResponse', @@ROWCOUNT)
		 
 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 6, '1.  AIR RESPONSE: >> C. DELETE ARS ..... ', NULL)

			--DELETE ARS 
			--FROM AirResponse ARS 
			--	INNER JOIN @DisconnectedResponse tmp ON ARS.airResponseKey = tmp.airResponseKey

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 7, '1.  AIR RESPONSE: >> C. DELETE ARS ..... ', @@ROWCOUNT)

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 8, '2.  AIR SUB REQUEST: >> A.  INSERT INTO @DISCONNECTEDSUBREQUEST', NULL)

			-- DELETE those records which exist in AirSubRequest and not exist in AirResponse

			--INSERT INTO @DisconnectedSubRequest
			--SELECT ASR.airSubRequestKey 
			--FROM AirSubRequest ASR
			--	INNER JOIN @airResNOTEXIST t ON ASR.airRequestKey = t.airRequestKey
			--WHERE airSubRequestKey NOT IN (SELECT DISTINCT airSubRequestKey FROM AirResponse)

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 9, '2.  AIR SUB REQUEST: >> A.  INSERT INTO @DISCONNECTEDSUBREQUEST', @@ROWCOUNT)

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 10, '2.  AIR SUB REQUEST: >> B.  INSERT INTO TIP_Report.dbo.AirSubRequest', NULL)

			--INSERT INTO TIP_Report.dbo.AirSubRequest
			--(	[airSubRequestKey],[airRequestKey], [airRequestDateTypeKey], [airRequestDepartureAirport], 
			--	[airRequestArrivalAirport], [airRequestDepartureDate], [airRequestDepartureDateVariance], 
			--	[airRequestArrivalDate], [airRequestArrivalDateVariance], [airRequestCalendarMonth], 
			--	[airRequestCalendarMinDays], [airRequestCalendarMaxDays], [airSubRequestLegIndex]
			--)
			--SELECT ASR.[airSubRequestKey], ASR.[airRequestKey], ASR.[airRequestDateTypeKey], 
			--	ASR.[airRequestDepartureAirport], ASR.[airRequestArrivalAirport], 
			--	ASR.[airRequestDepartureDate], ASR.[airRequestDepartureDateVariance], 
			--	ASR.[airRequestArrivalDate], ASR.[airRequestArrivalDateVariance], 
			--	ASR.[airRequestCalendarMonth], ASR.[airRequestCalendarMinDays], 
			--	ASR.[airRequestCalendarMaxDays], ASR.[airSubRequestLegIndex] 
			--FROM AirSubRequest ASR
			--	INNER JOIN @DisconnectedSubRequest tmp ON ASR.airSubRequestKey = tmp.airSubRequestKey

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 11, '2.  AIR SUB REQUEST: >> B.  INSERT INTO TIP_Report.dbo.AirSubRequest', @@ROWCOUNT)

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 12, '2.  AIR SUB REQUEST: >> C.  DELETE ASR', NULL)
			
			--DELETE ASR 
			--FROM AirSubRequest ASR 
			--	INNER JOIN @DisconnectedSubRequest tmp ON ASR.airSubRequestKey = tmp.airSubRequestKey

 		--			INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
			--			VALUES ('AIR', GETDATE(), 13, '2.  AIR SUB REQUEST: >> C.  DELETE ASR', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 4, '1.  AIR REQUEST: >> A.  INSERT INTO @DISCONNECTEDRESPONSE', NULL)

			-- DELETE those records which exist in AirRequest and not exist in AirSubRequest
			INSERT INTO @DisconnectedRequest
			SELECT airRequestKey FROM airRequest WHERE airRequestKey NOT IN (SELECT DISTINCT airRequestKey FROM AirSubRequest)

					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 5, '2. AIR REQUEST: >> A.  INSERT INTO @DISCONNECTEDRESPONSE', @@ROWCOUNT)
			
 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 6, '3.  AIR REQUEST: >> B.  INSERT INTO TIP_Report.dbo.AirRequest', NULL)
			
			INSERT INTO TIP_Report.dbo.AirRequest
			([airRequestKey], [airRequestTypeKey], [airRequestCreated], [isInternationalTrip])
			SELECT AR.[airRequestKey], AR.[airRequestTypeKey], AR.[airRequestCreated], AR.[isInternationalTrip] 
			FROM AirRequest AR
				INNER JOIN @DisconnectedRequest tmp ON AR.airRequestKey = tmp.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 7, '4.  AIR REQUEST: >> B.  INSERT INTO TIP_Report.dbo.AirRequest', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 8, '5.  AIR REQUEST: >> C.  DELETE AR', NULL)

			DELETE AR FROM AirRequest AR INNER JOIN @DisconnectedRequest tmp ON AR.airRequestKey = tmp.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 9, '6.  AIR REQUEST: >> C.  DELETE AR', @@ROWCOUNT)

			---------------------------- DELETE DISCONNECTED RECORDS OVER -------------------------------------------------------------------------------


 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 10, 'ARCHIVAL OF ACTUAL PAST DATED ROWS', NULL)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 11, '1.  INSERT INTO AIRREQUEST', NULL)
			
		----  INSERT INTO ARCHIVE DATABASE --------------
			INSERT INTO TIP_Report.dbo.AirRequest
				([airRequestKey], [airRequestTypeKey], [airRequestCreated], [isInternationalTrip])
			SELECT AR.[airRequestKey], AR.[airRequestTypeKey], AR.[airRequestCreated], AR.[isInternationalTrip] 
			FROM AirRequest AR
				INNER JOIN @airResNOTEXIST tmp ON AR.airRequestKey = tmp.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 12, '2.  INSERT INTO AIRREQUEST', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 13, '3.  INSERT INTO AIRSUBREQUEST', NULL)

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
				INNER JOIN @airResNOTEXIST tmp ON ASR.airRequestKey = tmp.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 14, '3.  INSERT INTO AIRSUBREQUEST', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 15, '4.  INSERT INTO AIRRESPONSE', NULL)
				
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
				INNER JOIN @airResNOTEXIST tmp ON AR.airRequestKey = tmp.airRequestKey
			
 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 16, '5.  INSERT INTO AIRRESPONSE', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 17, '6.  INSERT INTO AIRSEGMENTS', NULL)
			
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
				INNER JOIN @airResNOTEXIST tmp ON AR.airRequestKey = tmp.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 18, '7.  INSERT INTO AIRSEGMENTS', @@ROWCOUNT)

		---- INSERT ARCHIVE DATA COMPLETED --------------

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 19, '8.  DELETING FROM AIRSEGMENTS', NULL)

			DELETE ASeg -- STEP 2 : Delete AirSegments Records which is related to not exist
			FROM AirSegments ASeg
				INNER JOIN AirResponse AR ON ASeg.airResponseKey = AR.airResponseKey
				INNER JOIN AirSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
				INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey
			
 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 20, '9.  DELETING FROM AIRSEGMENTS', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 21, '10.  DELETING FROM AIRRESPONSE', NULL)
			
			DELETE AR -- STEP 3 : Delete AirResponse Records which is related to not exist
			FROM AirResponse AR
				INNER JOIN AirSubRequest ASR ON AR.airSubRequestKey = ASR.airSubRequestKey
				INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 22, '11.  DELETING FROM AIRRESPONSE', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 23, '12.  DELETING FROM AIRSUBREQUEST', NULL)

			DELETE ASR -- STEP 4 : Delete AirSubRequest Records which is related to not exist
			FROM AirSubRequest ASR 
				INNER JOIN @airResNOTEXIST notExist ON ASR.airRequestKey = notExist.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 24, '13.  DELETING FROM AIRSUBREQUEST', @@ROWCOUNT)

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 25, '14.  DELETING FROM AIRREQUEST', NULL)

			DELETE ARQ -- STEP 5 : Delete AirRequest Records which is related to not exist
			FROM AirRequest ARQ 
				INNER JOIN @airResNOTEXIST notExist ON ARQ.airRequestKey = notExist.airRequestKey

 					INSERT INTO @LogArchival(fldModule, fldDate, fldstep, fldDescription, fldRowsAffected)  
						VALUES ('AIR', GETDATE(), 26, '15.  DELETING FROM AIRREQUEST', @@ROWCOUNT)
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
