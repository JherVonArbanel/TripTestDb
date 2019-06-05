SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,Insert in TripRequest_car table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_InsertSaveUserSpecificCarRequest]
 @tripRequestKey  int,
 @carRequestKey int

 
AS
BEGIN
 
INSERT INTO TripRequest_car (tripRequestKey , carRequestKey)VALUES(@tripRequestKey, @carRequestKey) 
 	 
END
GO
