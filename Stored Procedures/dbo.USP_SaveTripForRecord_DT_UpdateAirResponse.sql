SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Update into [TripAirResponse] table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_UpdateAirResponse]
	 @PolicyReasonCodeID As int ,
	 @PolicyKey As int ,
	 @PolicyResaonCode As nvarchar(100),
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
