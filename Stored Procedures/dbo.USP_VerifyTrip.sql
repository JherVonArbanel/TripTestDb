SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_VerifyTrip]
(
	@tripKey	INT,
	@userKey	INT,
	@companyKey INT
)
AS
BEGIN
-- ci test meena, branch test--

	DECLARE @tblUser as table 
	(
	 	UserKey Int
	)
	
	INSERT INTO @tblUser
	SELECT DISTINCT userKey from Vault.dbo.GetAllArrangees(@userkey,@companyKey)
	IF ( SELECT COUNT (*) FROM @tblUser ) > 0 
	BEGIN 	
		SELECT tripkey FROM trip 		
		INNER JOIN Vault.dbo.[User] U on trip.userKey =  U.UserKey 
		INNER JOIN @tblUser TU ON U.userKey = TU.userKey  
		AND tripKey= @tripKey 
	END 
	ELSE 
	BEGIN
	 	SELECT tripkey FROM trip WHERE tripKey =@tripKey AND userKey = @userKey 
	END 
	
END


	
GO
