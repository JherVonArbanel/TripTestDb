SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <21st Sep 2011>
-- Description:	<Insert New Session Data In DataBase>
-- =============================================
CREATE PROCEDURE [dbo].[USP_AMADEUS_INSERT_NEW_SESSION] 
	-- Add the parameters for the stored procedure here
	@pSessionID				VARCHAR(20),
	@pSecurityToken			VARCHAR(30),
	@pSequenceNumber		VARCHAR(4),--,@pEnvironment VARCHAR(15)
	@pAmadeusConnectionKey	VARCHAR(4),
	@pCreatedFrom			VARCHAR(5)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO AmadeusSession (SessionID, SecurityToken, SequenceNumber, CreationTime, LastQueryTime, SessionStatus, 
								AmadeusConnectionKey, CreatedFrom, TotalNoOfTransactions)
	VALUES (@pSessionID, @pSecurityToken, (@pSequenceNumber), GETDATE(), GETDATE(), 'BUSY', @pAmadeusConnectionKey, @pCreatedFrom, '1')
	
	UPDATE AmadeusSessionLock 
	SET Locked = 'N', LastQueryTime = GETDATE() 
	WHERE AmadeusConnectionKey = @pAmadeusConnectionKey
	
END
GO
