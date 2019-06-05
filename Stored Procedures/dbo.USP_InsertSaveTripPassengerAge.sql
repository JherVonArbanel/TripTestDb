SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
--exec USP_InsertSaveTripPassengerAge 8072, '0|-1,1|-1', '5|2,7|2', '15|3,14|3'
CREATE PROCEDURE [dbo].[USP_InsertSaveTripPassengerAge]
	-- Add the parameters for the stored procedure here
	@tripKey INT
	,@infant VARCHAR(30) = ''
	,@child VARCHAR(30) = ''
	,@youth VARCHAR(30) = ''
AS
BEGIN
	
	SET NOCOUNT ON;
	
	Declare @tripRequestKey INT
			,@insertCount INT
			,@totalPassenger INT
			,@PassengerAge INT
			,@PassengerTypeKey FLOAT
			,@Passenger VARCHAR(10)
			,@PkID INT
	
	DECLARE @TblCommon AS TABLE (PkID INT IDENTITY(1,1), Value Varchar(5), IsInserted BIT DEFAULT(0))
	
	SET @tripRequestKey = (SELECT tripRequestKey FROM Trip WHERE tripKey =  @tripKey)
	
	IF(@infant <> '')
	BEGIN
		DELETE FROM @TblCommon
				
		INSERT INTO @TblCommon(Value)
		SELECT * FROM vault.dbo.ufn_CSVToTable (@infant)
		
		SET @totalPassenger = (SELECT COUNT(*) FROM @TblCommon)
		SET @insertCount = 1
		
		WHILE(@insertCount <= @totalPassenger)
		BEGIN
		
			SELECT TOP 1 @PkID = PkID, @Passenger = Value FROM @TblCommon WHERE IsInserted = 0
			SET @PassengerAge = (SELECT LEFT(@Passenger, ISNULL(NULLIF(CHARINDEX('|', @Passenger) -1, -1),LEN(@Passenger))))
			SET @PassengerTypeKey = (SELECT SUBSTRING(@Passenger,ISNULL(NULLIF(CHARINDEX('|', @Passenger), 0),LEN(@Passenger)) + 1, LEN(@Passenger)))
			
			INSERT INTO PassengerAge(TripRequestKey,TripKey,PassengerAge,PassengerTypeKey)
			VALUES(@tripRequestKey, @tripKey, @PassengerAge, @PassengerTypeKey)
			
			UPDATE @TblCommon SET IsInserted = 1 WHERE PkID = @PkID
			
		SET  @insertCount += 1  
		END
	END
	
	IF(@child <> '')
	BEGIN
		DELETE FROM @TblCommon
				
		INSERT INTO @TblCommon(Value)
		SELECT * FROM vault.dbo.ufn_CSVToTable (@child)
		
		SET @totalPassenger = (SELECT COUNT(*) FROM @TblCommon)
		SET @insertCount = 1
		
		WHILE(@insertCount <= @totalPassenger)
		BEGIN
			SELECT TOP 1 @PkID = PkID, @Passenger = Value FROM @TblCommon WHERE IsInserted = 0
			SET @PassengerAge = (SELECT LEFT(@Passenger, ISNULL(NULLIF(CHARINDEX('|', @Passenger) -1, -1),LEN(@Passenger))))
			SET @PassengerTypeKey = (SELECT SUBSTRING(@Passenger,ISNULL(NULLIF(CHARINDEX('|', @Passenger), 0),LEN(@Passenger)) + 1, LEN(@Passenger)))
			
			INSERT INTO PassengerAge(TripRequestKey,TripKey,PassengerAge,PassengerTypeKey)
			VALUES(@tripRequestKey, @tripKey, @PassengerAge, @PassengerTypeKey)
			
			UPDATE @TblCommon SET IsInserted = 1 WHERE PkID = @PkID
			
		SET  @insertCount += 1  
		END
	END
	
	IF(@youth <> '')
	BEGIN
		DELETE FROM @TblCommon
				
		INSERT INTO @TblCommon(Value)
		SELECT * FROM vault.dbo.ufn_CSVToTable (@youth)
		
		SET @totalPassenger = (SELECT COUNT(*) FROM @TblCommon)
		SET @insertCount = 1
		
		WHILE(@insertCount <= @totalPassenger)
		BEGIN
			SELECT TOP 1 @PkID = PkID, @Passenger = Value FROM @TblCommon WHERE IsInserted = 0
			SET @PassengerAge = (SELECT LEFT(@Passenger, ISNULL(NULLIF(CHARINDEX('|', @Passenger) -1, -1),LEN(@Passenger))))
			SET @PassengerTypeKey = (SELECT SUBSTRING(@Passenger,ISNULL(NULLIF(CHARINDEX('|', @Passenger), 0),LEN(@Passenger)) + 1, LEN(@Passenger)))
			
			INSERT INTO PassengerAge(TripRequestKey,TripKey,PassengerAge,PassengerTypeKey)
			VALUES(@tripRequestKey, @tripKey, @PassengerAge, @PassengerTypeKey)
			
			UPDATE @TblCommon SET IsInserted = 1 WHERE PkID = @PkID
			
		SET  @insertCount += 1  
		END
	END
   
   
END
GO
