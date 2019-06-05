SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Dharmendra>
-- Create date: <28Dec2011>
-- Description:	<Records Insert into TripStatusHistory table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_DT_StatusHistory]
	 @tripKey As int ,
	 @tripStatusKey As int ,
	 @createdDateTime As datetime
	 
AS
BEGIN
 
INSERT INTO [TripStatusHistory] 
			([tripKey],[tripStatusKey],[createdDateTime]) 
		values
			(@tripKey, @tripStatusKey, @createdDateTime)
                    
END


GO
