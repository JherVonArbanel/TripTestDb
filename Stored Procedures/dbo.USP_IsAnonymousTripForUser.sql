SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <09/Dec/2015>
-- Description:	<To checked the trip privacyType for logged in user>
-- =============================================
CREATE PROCEDURE [dbo].[USP_IsAnonymousTripForUser]
	-- Add the parameters for the stored procedure here
	 @tripKey int ,                                
	 @loggedInUserKey BIGINT = 0 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF EXISTS(
	SELECT PRIVACYTYPE FROM TRIP
	WHERE tripKey=@tripKey and userKey=@loggedInUserKey)
	BEGIN
		SELECT 0 AS IsAnonymous		
	END
	ELSE 
		Begin
			IF EXISTS(
			SELECT PRIVACYTYPE FROM TRIP
			WHERE tripKey=@tripKey AND privacyType=2)
			BEGIN
				SELECT 1 AS IsAnonymous
			END
			ELSE
			BEGIN
				SELECT 0 AS IsAnonymous		
			END
		End
	
END
GO
