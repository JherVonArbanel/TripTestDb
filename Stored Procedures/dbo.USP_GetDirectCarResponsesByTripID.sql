SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,28Dec2011,>
-- Description:	<Description,SELECT View from Trip table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetDirectCarResponsesByTripID]
@tripKey int

 
AS
BEGIN
 
SELECT vw_DirectCarResponse.*, TripcarResponse.* FROM vw_DirectCarResponse LEFT OUTER JOIN TripcarResponse ON vw_DirectCarResponse.carResponseKey = TripcarResponse.carResponseKey where tripKey=@tripKey
END
GO
