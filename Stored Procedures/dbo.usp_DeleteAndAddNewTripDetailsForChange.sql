SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE  [dbo].[usp_DeleteAndAddNewTripDetailsForChange]
@recordLocator varchar(20),
@status int
AS
 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @tripKey  AS INT 
	SET @tripKey  = ( SELECT tripKey  FROM Trip WHERE recordLocator = @recordLocator ) 
	
	SELECT @tripKey 
	
	IF @status = 5 /* For Cancelled */
	BEGIN
	
		UPDATE Trip SET tripStatusKey = 5 WHERE recordLocator =@recordLocator AND tripStatusKey <> 1 and tripStatusKey <> 17
		/* UserHistory # 1024 */
		IF @@ROWCOUNT <> 0
			BEGIN
				UPDATE TripAirResponse 
				SET  actualAirPrice = 0.0, actualAirTax = 0.0
				WHERE TripKey IN
					(SELECT TripKey FROM Trip Where recordLocator =@recordLocator)
			END
			
	END	
	ELSE IF @status = 13 /* For Banked */
	BEGIN
	
		UPDATE Trip SET tripStatusKey = 13 WHERE recordLocator =@recordLocator AND tripStatusKey <> 1and tripStatusKey <> 17
	END	
	ELSE
	BEGIN
		SELECT * FROM TripAirResponse WHERE tripKey = @tripKey 
	 	
		UPDATE TripAirSegmentOptionalServices SET ISDELETED = 1   WHERE  tripKey = @tripKey 		
		UPDATE TripAirSegments SET ISDELETED = 1  fROM TripAirSegments SEG INNER JOIN  TripAirLegs LEG  ON LEG.tripAirLegsKey = SEG.tripAirLegsKey 
		WHERE LEG.tripKey = @tripKey 	    
		UPDATE TripAirLegs  SET ISDELETED = 1 WHERE tripKey = @tripKey     
		
		IF(@status <> 12) /* Exchanged Status is added.*/
		BEGIN
		Update TripAirResponseTax 
		Set TripAirResponseTax.Active  = 0 
		FROM TripAirResponseTax TT INNER JOIN TripAirResponse   TA on TT.airResponseKey = Ta.airResponseKey 
		Where TripKey = @tripKey
		END
		
		Update TripPassengerAirPreference set Active= 0 where TripKey = @tripKey
		
		/* Anupam has changed - Task # 1031*/
		Update TripPassengerUDIDInfo set Active = 0 where TripKey = @tripKey 
	END
GO
