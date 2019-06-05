SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Jayant Guru>
-- Create date: <21st Sep 2011>
-- Description:	<Selects the session details>
-- =============================================
CREATE PROCEDURE [dbo].[USP_AMADEUS_SESSION_DETAILS]
	-- Add the parameters for the stored procedure here
	@pAmadeusConnectionKey VARCHAR(4)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
    
	SELECT pkID, OrganizationID, UserID, OfficeID, Environment, OriginatorTypeCode, ReferenceIdentifier, ReferenceQualifier, [Password]
		,PasswordLength, PasswordDataType, MinimumSession, MaximumSession, DefaultSessionTimeOut, ActualSessionTimeOut, NumberOfAttempt
		,DefaultResponseTimeOut, ActualResponseTimeOut, MinSequenceNumber, MaxSequenceNumber, amadeusConnectionKey
	FROM AmadeusConnection 
	WHERE AmadeusConnectionKey = @pAmadeusConnectionKey

	SELECT TotalRowCount = COUNT(pkID) 
	FROM AmadeusSession 
	WHERE AmadeusConnectionKey = @pAmadeusConnectionKey AND CreatedFrom = 'UTIL' AND amadeusConnectionKey = @pAmadeusConnectionKey
END


GO
