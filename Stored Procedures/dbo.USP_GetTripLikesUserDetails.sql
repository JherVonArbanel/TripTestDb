SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 29-02-2016
-- Description:	GetTripLikesUserDetails
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetTripLikesUserDetails]
 @tripKey INT
AS
BEGIN

SELECT UR.UserKey, UR.userFirstName,UR.userLastName,UM.ImageURL,UM.BadgeName,ADR.city FROM Trip..TripLike TL
   INNER JOIN Loyalty..UserMap UM ON TL.userKey = UM.UserId
   INNER JOIN Vault..[User] UR ON UR.userKey = UM.UserId
   INNER JOIN Vault..[UserProfile] UP ON UP.userKey = UM.UserId
   LEFT OUTER JOIN Vault..[Address] ADR ON ADR.addressKey = UP.homeAddressKey
   WHERE TL.tripKey =@tripKey

END
GO
