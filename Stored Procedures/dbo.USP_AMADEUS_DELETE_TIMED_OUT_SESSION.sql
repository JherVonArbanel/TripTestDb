SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <22nd Sep 2011>
-- Description:	<To delete session which has timed out>
-- =============================================
CREATE PROCEDURE [dbo].[USP_AMADEUS_DELETE_TIMED_OUT_SESSION] 
	-- Add the parameters for the stored procedure here
	@pAmadeusConnectionKey VARCHAR(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @actualSessionTimeOut INT, @lockingTimeOut INT 
	
	SELECT @actualSessionTimeOut = ActualSessionTimeOut, @lockingTimeOut = LockingTimeOut 
	FROM AmadeusConnection 
	WHERE amadeusConnectionKey = @pAmadeusConnectionKey
	
    -- Insert statements for procedure here
	SELECT SessionID, SecurityToken, SequenceNumber, CreationTime, LastQueryTime, amadeusConnectionKey, CreatedFrom, TotalNoOfTransactions 
	FROM AmadeusSession 
	WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @actualSessionTimeOut 
		AND SessionStatus = 'AVAILABLE' AND amadeusConnectionKey = @pAmadeusConnectionKey
		
	SELECT SessionID, SecurityToken, SequenceNumber, CreationTime, LastQueryTime, amadeusConnectionKey, CreatedFrom, TotalNoOfTransactions 
	FROM AmadeusSession 
	WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @actualSessionTimeOut 
		AND SessionStatus = 'BUSY' AND amadeusConnectionKey = @pAmadeusConnectionKey
		
	SELECT Environment FROM AmadeusConnection WHERE amadeusConnectionKey = @pAmadeusConnectionKey
	
	DELETE FROM AmadeusSession 
	WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @actualSessionTimeOut AND SessionStatus = 'AVAILABLE' 
		AND amadeusConnectionKey = @pAmadeusConnectionKey
	DELETE FROM AmadeusSession 
	WHERE DATEDIFF(MI,LastQueryTime,GETDATE()) >= @actualSessionTimeOut AND SessionStatus = 'BUSY' 
		AND amadeusConnectionKey = @pAmadeusConnectionKey
			
	UPDATE AmadeusSessionLock SET Locked = 'N', LastQueryTime = GETDATE() 
	WHERE DATEDIFF(MI, LastQueryTime, GETDATE()) >= @lockingTimeOut AND amadeusConnectionKey = @pAmadeusConnectionKey
		
END

GO
