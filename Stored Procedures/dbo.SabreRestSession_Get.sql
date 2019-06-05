SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <23rd Jun 17>
-- Description:	<To get the Sessionless Token for Sabre Rest api>
-- Execution: <Exec [dbo].[SabreRestSession_Get]>
-- =============================================
CREATE PROCEDURE [dbo].[SabreRestSession_Get]
	-- Add the parameters for the stored procedure here
@sabreToken NVARCHAR(MAX)='',
@isCert bit=0,
@connectionKey int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Select count of TotalSession in table.
	Declare @SessionCount int
	Select @SessionCount = COUNT(SessionID) from SabreRestSession
    -- Insert statements for procedure here
	
	If(@SessionCount >= 0)
	BEGIN
	    IF(@sabreToken = '')
	    BEGIN
			IF(@connectionKey != 0)
			BEGIN
				IF EXISTS(SELECT SessionToken from SabreRestSession 
				WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60 AND isCert = @isCert AND ConnectionID = @connectionKey)
				BEGIN
					SELECT top 1 SessionToken from SabreRestSession 
					WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60 AND isCert = @isCert AND ConnectionID = @connectionKey
					ORDER BY SessionID DESC
				END
				ELSE
				BEGIN
					SELECT '' as SessionToken
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SessionToken from SabreRestSession 
				WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60 AND isCert = @isCert)
				BEGIN
					SELECT top 1 SessionToken from SabreRestSession 
					WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60 AND isCert = @isCert
					ORDER BY SessionID DESC
				END
				ELSE
				BEGIN
					SELECT '' as SessionToken
				END
			END
		END
		ELSE
		BEGIN
			IF(@connectionKey != 0)
			BEGIN
				IF EXISTS(SELECT SessionToken from SabreRestSession 
				WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60
				AND SessionToken <> @sabreToken AND isCert = @isCert AND ConnectionID = @connectionKey)
				BEGIN
					SELECT top 1 SessionToken from SabreRestSession 
					WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60
					AND SessionToken <> @sabreToken AND isCert = @isCert AND ConnectionID = @connectionKey
					ORDER BY SessionID DESC
				END
				ELSE
				BEGIN
					SELECT '' as SessionToken
				END
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT SessionToken from SabreRestSession 
				WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60
				AND SessionToken <> @sabreToken AND isCert = @isCert)
				BEGIN
					SELECT top 1 SessionToken from SabreRestSession 
					WHERE  DATEDIFF(SS,GETDATE(),SessionExpDate) > 60
					AND SessionToken <> @sabreToken AND isCert = @isCert
					ORDER BY SessionID DESC
				END
				ELSE
				BEGIN
					SELECT '' as SessionToken
				END
			END
		END
	END
	ELSE
	BEGIN
		SELECT '' as SessionToken
	END
END
GO
