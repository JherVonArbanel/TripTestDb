SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <22nd Sep 2011>
-- Description:	<To check and select if a session is available>
-- =============================================
--EXEC USP_AMADEUS_CHECK_AVAILABLE_SESSION '2','NEW_SESSION'
CREATE PROCEDURE [dbo].[USP_AMADEUS_CHECK_AVAILABLE_SESSION] 
	-- Add the parameters for the stored procedure here
	@pAmadeusConnectionKey VARCHAR(15),
	@pCase VARCHAR(15) = 'CHECK_SESSION'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@pCase = 'CHECK_SESSION')
	BEGIN				
		DECLARE @avlSessionCount INT
				,@avlSessionWeb INT
				,@totalSessionWeb INT
				,@noOfWebSessionCanBeCreated INT
				,@actualSessionTimeOut INT
				,@lockCount INT
				,@lockingTimeOut INT

		SELECT @actualSessionTimeOut = ActualSessionTimeOut, @lockingTimeOut = LockingTimeOut FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey
		SET @avlSessionCount = ISNULL((select COUNT(SessionStatus) from AmadeusSession where SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut),0)

	--****WHEN AVAILABLE SESSION IS ZERO*******
		IF(@avlSessionCount = 0)
		BEGIN
			SET @totalSessionWeb = ISNULL((SELECT COUNT(CreatedFrom) FROM AmadeusSession WHERE CreatedFrom = 'WEB' AND amadeusConnectionKey = @pAmadeusConnectionKey AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut) ,0)
			SET @noOfWebSessionCanBeCreated = ((SELECT MaximumSession FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey) - (SELECT MinimumSession FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey))
			--****CHECKS IF ANY SESSION CAN BE CREATED FROM WEB APPLICATION*****
			IF(@totalSessionWeb < @noOfWebSessionCanBeCreated)
			BEGIN				
				SELECT CanCreateSession = 'TRUE', OrganizationID, UserID, OfficeID, OriginatorTypeCode, ReferenceIdentifier, 
					ReferenceQualifier, [Password], PasswordLength, PasswordDataType
				FROM AmadeusConnection 
				WHERE amadeusConnectionKey = @pAmadeusConnectionKey
			END
			ELSE
			BEGIN
				SELECT CanCreateSession = 'FALSE'
			END
		END
	--****WHEN SESSION IS AVAILABLE*******
	ELSE IF(@avlSessionCount > 0)
		BEGIN
			DECLARE @pkID INT, @SequenceNo INT
			SELECT TOP 1 @pkID = pkID, @SequenceNo = SequenceNumber 
			FROM AmadeusSession 
			WHERE SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey 
				AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut
			
			IF(@SequenceNo = (SELECT MaxSequenceNumber FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey))
			BEGIN
				UPDATE AmadeusSession 
				SET SessionStatus = 'BUSY', 
					SequenceNumber = (SELECT MinSequenceNumber FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey) 
				WHERE pkID = @pkID
			END
			ELSE
			BEGIN
				UPDATE AmadeusSession SET SessionStatus = 'BUSY' WHERE pkID = @pkID
			END
			
			SELECT TOP 1 CanCreateSession = 'AVAILABLE', pkID, SessionID, SecurityToken, SequenceNumber, 
				CreationTime = CONVERT(VARCHAR, CreationTime, 121), 
				LastQueryTime = CONVERT(VARCHAR, LastQueryTime, 121), SessionStatus, amadeusConnectionKey, CreatedFrom
			FROM AmadeusSession 
			WHERE pkID = @pkID
		END
	END
	--EXPLICIT REQUEST FOR NEW SESSION IN CASE OF BOOKING
	ELSE IF(@pCase = 'NEW_SESSION')
	BEGIN
		SELECT CanCreateSession = 'TRUE', OrganizationID, UserID, OfficeID, OriginatorTypeCode, ReferenceIdentifier, ReferenceQualifier, 
			[Password], PasswordLength, PasswordDataType
		FROM AmadeusConnection 
		WHERE amadeusConnectionKey = @pAmadeusConnectionKey
	END
END
GO
