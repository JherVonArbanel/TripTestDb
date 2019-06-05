SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<GetTravelRequestIDByTripID from Trip table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetTravelRequestIDByTripID]
	 @TripKey As int 
AS
BEGIN

select tripRequestKey  from Trip where tripKey = @tripKey
                    
END
GO
