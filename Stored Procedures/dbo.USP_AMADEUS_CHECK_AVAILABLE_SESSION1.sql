SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <22nd Sep 2011>
-- Description:	<To check and select if a session is available>
-- =============================================
--EXEC USP_AMADEUS_CHECK_AVAILABLE_SESSION1 '2'
CREATE PROCEDURE [dbo].[USP_AMADEUS_CHECK_AVAILABLE_SESSION1] 
	-- Add the parameters for the stored procedure here
	@pAmadeusConnectionKey varchar(15)
	,@pCase varchar(15) = 'CHECK_SESSION'
	
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

--SET @actualSessionTimeOut = (SELECT ActualSessionTimeOut FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey)
--SET @lockingTimeOut = (SELECT LockingTimeOut FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey)
--****COMMENTED BY JAYANT : THE DELETE IS DONE THROUGH SESSION SIGN OUT SCHEDULER*****
--DELETE FROM AmadeusSession WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @actualSessionTimeOut AND SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey
--DELETE FROM AmadeusSession WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @actualSessionTimeOut AND SessionStatus = 'BUSY' AND amadeusConnectionKey = @pAmadeusConnectionKey
--END****COMMENTED BY JAYANT : THE DELETE IS DONE THROUGH SESSION SIGN OUT SCHEDULER*****

UPDATE AmadeusSessionLock SET Locked = 'N', LastQueryTime = GETDATE() WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @lockingTimeOut AND amadeusConnectionKey = @pAmadeusConnectionKey

SET @avlSessionCount = ISNULL((select COUNT(SessionStatus) from AmadeusSession where SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut),0)
--PRINT @avlSessionCount
--****WHEN AVAILABLE SESSION IS ZERO*******
IF(@avlSessionCount = 0)
	BEGIN
		SET @totalSessionWeb = ISNULL((SELECT COUNT(CreatedFrom) FROM AmadeusSession WHERE CreatedFrom = 'WEB' AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut) ,0)
		SET @noOfWebSessionCanBeCreated = ((SELECT MaximumSession FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey) - (SELECT MinimumSession FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey))
		SET @lockCount = ISNULL((SELECT COUNT(Locked) FROM AmadeusSessionLock WHERE amadeusConnectionKey = @pAmadeusConnectionKey),0)
		
		--****CHECKS IF ANY SESSION CAN BE CREATED FROM WEB APPLICATION*****
		IF(@totalSessionWeb < @noOfWebSessionCanBeCreated)
			BEGIN	
			--***CHECKS IF THERE EXIST ANY ROW IN THE LOCK TABLE. IF NOT THEN A NEW ROW IS INSERTED AND STATUS IS SET AS LOCKED i.e "Y"******
				IF(@lockCount = 0)
					BEGIN
						INSERT INTO AmadeusSessionLock (amadeusConnectionKey,Locked,LastQueryTime) VALUES (@pAmadeusConnectionKey,'Y',GETDATE())
						SELECT CanCreateSession = 'TRUE', OrganizationID,UserID,OfficeID,OriginatorTypeCode,ReferenceIdentifier,ReferenceQualifier,[Password],PasswordLength,PasswordDataType
						FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey
					END
				ELSE
					BEGIN
						IF((SELECT Locked FROM AmadeusSessionLock WHERE amadeusConnectionKey = @pAmadeusConnectionKey) = 'Y')
							BEGIN
								SELECT CanCreateSession = 'FALSE'
							END
						ELSE	
							BEGIN
								UPDATE AmadeusSessionLock SET Locked = 'Y',LastQueryTime = GETDATE() WHERE amadeusConnectionKey = @pAmadeusConnectionKey
								
								SELECT CanCreateSession = 'TRUE', OrganizationID,UserID,OfficeID,OriginatorTypeCode,ReferenceIdentifier,ReferenceQualifier,[Password],PasswordLength,PasswordDataType
								FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey
							END
					END
			END		
		--END****CHECKS IF ANY SESSION CAN BE CREATED FROM WEB APPLICATION*****
		ELSE
		BEGIN
			SELECT CanCreateSession = 'FALSE'
		END
	END
	--****WHEN SESSION IS AVAILABLE*******
ELSE IF(@avlSessionCount > 0)
	BEGIN
		DECLARE @pkID INT
				,@SequenceNo INT
				
		--SET @pkID = (SELECT TOP 1 pkID FROM AmadeusSession WHERE SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut)
		--SET @SequenceNo = (SELECT SequenceNumber FROM AmadeusSession WHERE pkID = @pkID)
		SELECT TOP 1 @pkID = pkID, @SequenceNo = SequenceNumber FROM AmadeusSession WHERE SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey AND DATEDIFF(MI,LastQueryTime,GETDATE()) <= @actualSessionTimeOut
		
		IF(@SequenceNo = (SELECT MaxSequenceNumber FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey))
			BEGIN
			
				--******COMMENTED BY JAYANT : THE LastQueryTime SHOULD ONLY BE UPDATEED WHEN A TRANSACTION IS SUCCESSFUL*****
				--UPDATE AmadeusSession SET LastQueryTime = GETDATE(), SessionStatus = 'BUSY', SequenceNumber = (SELECT MinSequenceNumber FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey) WHERE pkID = @pkID
				--END******COMMENTED BY JAYANT : THE LastQueryTime SHOULD ONLY BE UPDATEED WHEN A TRANSACTION IS SUCCESSFUL*****
				
				UPDATE AmadeusSession SET SessionStatus = 'BUSY', SequenceNumber = (SELECT MinSequenceNumber FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey) WHERE pkID = @pkID
			END
		ELSE
			BEGIN
				--******COMMENTED BY JAYANT : THE LastQueryTime SHOULD ONLY BE UPDATEED WHEN A TRANSACTION IS SUCCESSFUL*****
				--UPDATE AmadeusSession SET LastQueryTime = GETDATE(), SessionStatus = 'BUSY' WHERE pkID = @pkID
				--END******COMMENTED BY JAYANT : THE LastQueryTime SHOULD ONLY BE UPDATEED WHEN A TRANSACTION IS SUCCESSFUL*****
				
				UPDATE AmadeusSession SET SessionStatus = 'BUSY' WHERE pkID = @pkID
			END
		
		SELECT TOP 1 CanCreateSession = 'AVAILABLE', pkID,SessionID,SecurityToken,SequenceNumber, CreationTime = convert(varchar,CreationTime,121) ,LastQueryTime = convert(varchar,LastQueryTime,121),SessionStatus,amadeusConnectionKey,CreatedFrom
		FROM AmadeusSession WHERE pkID = @pkID
		
END
END
ELSE IF(@pCase = 'NEW_SESSION')
BEGIN
	SELECT CanCreateSession = 'TRUE', OrganizationID,UserID,OfficeID,OriginatorTypeCode,ReferenceIdentifier,ReferenceQualifier,[Password],PasswordLength,PasswordDataType
	FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey
END
END

GO
