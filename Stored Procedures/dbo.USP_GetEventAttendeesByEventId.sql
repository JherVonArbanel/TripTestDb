SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Anupam Patel
-- Create date: 11-Aug-2014
-- Description:	It is used to get event attendee list of event
-- USP_GetEventAttendeesByEventId 35610
-- =============================================

CREATE PROCEDURE [dbo].[USP_GetEventAttendeesByEventId]
	-- Add the parameters for the stored procedure here
	@EventKey INT,
	@LogedInUserKey Bigint=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     
	SELECT DISTINCT EA.eventAttendeeKey,EA.eventKey,EA.userKey,EA.attendeeStatusKey,U.userFirstName,U.userLastName,
	(CASE WHEN UM.UserImageData IS NOT NULL THEN 1 ELSE 0 END) as ImageDataAvailable,
	UM.ImageURL,A.originAirportCode,EA.isHost,EA.attendeeFirstName,EA.attendeeLastName,UC.chatStreamKey,UC.readCount
	FROM [Trip].[dbo].[EventAttendees] EA WITH(NOLOCK)
	INNER JOIN [Trip].[dbo].[Events] E WITH(NOLOCK) ON EA.[eventKey] = E.[eventKey] AND EA.[eventKey] = @EventKey AND E.IsDeleted = 0 
	LEFT OUTER JOIN  (SELECT Distinct UserKey,originAirportCode
					  From [Vault].[dbo].[AirPreference]
					  Where UserKey > 0
					  Group By UserKey,originAirportCode) A ON A.userKey = EA.userKey
	LEFT JOIN [Vault].[dbo].[User] U WITH(NOLOCK) ON U.userKey = EA.UserKey 
	LEFT JOIN [Loyalty].[dbo].[UserMap] UM WITH(NOLOCK) ON UM.userID = EA.userKey
	LEFT JOIN [Trip].[dbo].[UserChatMapping] UC WITH(NOLOCK) ON UC.fromUserKey=U.userKey AND UC.toUserKey=@LogedInUserKey
	
	
	ORDER BY 1 ASC	
	
END
GO
