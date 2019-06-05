SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		<Dharmendra>
-- Create date: <27Dec2011>
-- Description:	<Records Insert into TripStatusHistory table>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveTripForRecord_TripStatusHistory]
	 @tripKey As int ,
	 @tripStatusKey As int ,
	 @createdDateTime As datetime 
	 
AS
BEGIN
 
INSERT INTO [TripStatusHistory] 
		([tripKey],[tripStatusKey],[createdDateTime]) 
	VALUES
		(@tripKey, @tripStatusKey, @createdDateTime)

END


GO
