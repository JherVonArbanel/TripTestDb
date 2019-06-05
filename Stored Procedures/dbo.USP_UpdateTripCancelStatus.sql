SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_UpdateTripCancelStatus] (@pnr VARCHAR(6))
AS
UPDATE Trip 
SET cancellationflag=1 
WHERE recordLocator=@pnr
GO
