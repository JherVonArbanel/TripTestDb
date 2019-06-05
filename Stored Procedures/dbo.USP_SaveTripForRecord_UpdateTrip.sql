SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Update  Trip table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_UpdateTrip]
	 @startdate As datetime ,
	 @enddate As datetime ,
	 @tripKey As int
	 	 
AS
BEGIN
 
update trip 
	set 
		startdate	= @startdate,
		enddate		= @enddate 
	where 
		tripKey		= @tripKey

END


GO
