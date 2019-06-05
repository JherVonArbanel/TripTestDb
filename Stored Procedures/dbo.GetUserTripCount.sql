SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GetUserTripCount]    
(    
  
 @UserGUID nvarchar(500)
,@SiteGUID nvarchar(500)
)    
AS    
BEGIN    
 DECLARE @SiteKey INT, @UserKey INT   
 
	SELECT	 @SiteKey=SiteKey
	FROM	 Vault..SiteConfiguration with(nolock)
	--WHERE siteKey = 64 AND @SiteGUID = '2D620B87-E702-4AE9-A91F-88F864FDC2D1'
	WHERE	 data.value('(/Site/siteGUID/node())[1]', 'NVARCHAR(500)') = @SiteGUID

	SELECT @Userkey = UserKey FROM Vault..[User] with(nolock) WHERE UserGUID = @UserGUID
	Select count(*)TripCount from Trip.dbo.trip t
	LEFT OUTER JOIN Trip.dbo.TripPassengerInfo TPI ON t.tripKey = TPI.TripKey
	where (t.userKey =@Userkey  OR TPI.PassengerKey=@UserKey)
	and Sitekey =@SiteKey 
	and recordlocator IS NOT NULL
    
END   
  
GO
