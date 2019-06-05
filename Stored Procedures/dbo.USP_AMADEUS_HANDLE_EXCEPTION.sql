SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <29th Sep 2011>
-- Description:	<To Unlock Session>
-- =============================================
--EXEC USP_AMADEUS_HANDLE_EXCEPTION 'UNLOCK_SESSION','00QG9T7ghd'
CREATE PROCEDURE [dbo].[USP_AMADEUS_HANDLE_EXCEPTION]
	-- Add the parameters for the stored procedure here
	@pCase VARCHAR(20)
	,@pID VARCHAR(20) = ''
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
    -- Insert statements for procedure here
	IF(@pCase = 'UNLOCK')
	BEGIN
		UPDATE AmadeusSessionLock SET Locked = 'N', LastQueryTime = GETDATE() WHERE amadeusConnectionKey = @pID
	END
	
	ELSE IF(@pCase = 'UNLOCK_SESSION')
	BEGIN
		DECLARE @totalNoOfTrans INT
		SET @totalNoOfTrans = (SELECT TotalNoOfTransactions FROM AmadeusSession WHERE SessionID = @pID)
		UPDATE AmadeusSession SET SessionStatus='AVAILABLE',TotalNoOfTransactions = (@totalNoOfTrans + 1) WHERE SessionID = @pID
	END
	
	ELSE IF(@pCase = 'UNLOCK_BUSY')
	BEGIN
		UPDATE AmadeusSession SET SessionStatus='AVAILABLE' WHERE SessionID = @pID
	END
	
END

GO
