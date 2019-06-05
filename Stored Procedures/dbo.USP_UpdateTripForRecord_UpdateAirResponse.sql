SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Update TripAirResponse table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_UpdateTripForRecord_UpdateAirResponse]
	 @PolicyReasonCodeID As int ,
	 @PolicyKey As int ,
	 @PolicyResaonCode As nvarchar(200),
	 @airResponseKey As uniqueidentifier
	 
AS
BEGIN
 
Update  [TripAirResponse] 
		set 
			PolicyReasonCodeID	=  @PolicyReasonCodeID,
			PolicyKey			=  @PolicyKey, 
			PolicyResaonCode	=  @PolicyResaonCode
		Where 
			airResponseKey		=  @airResponseKey

END

GO
