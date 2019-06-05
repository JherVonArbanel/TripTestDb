SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik	
-- Create date: 19/Feb/2016
-- Description:	It is used to get alerts for newly added 
-- Exec USP_GetAcceptInvitationForTimeLine null
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetAcceptInvitationForTimeLine]
	-- Add the parameters for the stored procedure here
	@StartDate Datetime
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    
    IF(@StartDate IS NULL)
    BEGIN
    	SELECT UM.ParentId as userKey, U.userFirstName, U.userLastName,UM.ImageURL,UM.CreatedDate  FROM Loyalty..UserMap UM
    	INNER JOIN Vault..[User] U ON U.userKey = UM.UserId AND UM.ParentId > 0
    	 order by UM.CreatedDate 
    END
    ELSE
    BEGIN
		SELECT UM.ParentId as userKey, U.userFirstName, U.userLastName,UM.ImageURL,UM.CreatedDate  FROM Loyalty..UserMap UM
    	INNER JOIN Vault..[User] U ON U.userKey = UM.UserId AND	UM.CreatedDate > @StartDate  AND UM.ParentId > 0
    	 order by UM.CreatedDate 
    END        
	
END

GO
