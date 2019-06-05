SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetEventOptionsBasedOnTrip] 
(      
	@tripId BIGINT = 0 ,      
	@userId BIGINT = 0       
)  
AS
BEGIN
	DECLARE @EventID AS BIGINT =0 ;
	
	SELECT       
		@EventID = eventKey 
	  FROM       
	   AttendeeTravelDetails ATD  WITH (NOLOCK)      
	   RIGHT OUTER JOIN EventAttendees EA  WITH (NOLOCK) on ATD.eventAttendeekey = Ea.eventAttendeeKey       
	  WHERE       
	   attendeeTripKey = @tripId  
	   
	 SELECT eventKey, userKey, eventViewershipType, isInviteFromAttendeeAllowed, isAttendeeActivityEditAllowed FROM Trip..Events WHERE eventKey = @EventID;
	 
END
GO
