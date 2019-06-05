SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <22nd Sep 2011>
-- Description:	<Update session status after a transaction>
--exec [USP_AMADEUS_UPDATE_SESSION_STATUS] '013CDELIAU', '6'
-- =============================================
CREATE PROCEDURE [dbo].[USP_AMADEUS_UPDATE_SESSION_STATUS] 
	-- Add the parameters for the stored procedure here
	@pSessionID		VARCHAR(10),
	@pSequenceNo	VARCHAR(5),
	@pAddTran		VARCHAR(2) = '1'
	--@pCase varchar(15)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
 --   IF(@pCase = 'PKID')
 --   BEGIN
	--	UPDATE AmadeusSession SET LastQueryTime = GETDATE(), SessionStatus = 'AVAILABLE' WHERE pkID = @pID
	--END
	--ELSE IF (@pCase = 'SESSIONID')
	--BEGIN
	--	UPDATE AmadeusSession SET LastQueryTime = GETDATE(), SessionStatus = 'AVAILABLE' WHERE SessionID = @pID
	--END
	DECLARE @TotalTrans INT
	SET @TotalTrans = (SELECT TotalNoOfTransactions FROM AmadeusSession WHERE SessionID = @pSessionID)
				
	UPDATE AmadeusSession 
	SET LastQueryTime = GETDATE(), 
		SessionStatus = 'AVAILABLE', 
		SequenceNumber = @pSequenceNo, 
		TotalNoOfTransactions = (@TotalTrans + CONVERT(INT,@pAddTran))  
	WHERE SessionID = @pSessionID
	
END
GO
