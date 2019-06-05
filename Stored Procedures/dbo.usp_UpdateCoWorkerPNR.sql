SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[usp_UpdateCoWorkerPNR]      
(     
@UserKey INT=0,
@tripKey INt=0,
@FirstName  NVARCHAR(400),
@LastName  NVARCHAR(400),
@EmailAddress VARCHAR(100)
)      
AS    
BEGIN    
IF (@tripKey !=0)
BEGIN
	UPDATE Trip
	SET UserKey = @UserKey
	WHERE tripKey = @tripKey

	UPDATE TripPassengerInfo
	SET PassengerFirstName = @FirstName,
	PassengerLastName = @LastName,
	PassengerEmailID = @EmailAddress,
	PassengerKey = @UserKey
	WHERE tripKey = @tripKey
END
END
GO
