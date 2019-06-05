SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 22/10/2018 8:04PM
-- Description:	Car Response with unique vendor as per type
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetCarResponsesForRequestType]
	-- Add the parameters for the stored procedure here
	@carRequestKey as int, 
	@RequestType as int =1
AS
BEGIN
	Select * FROM (
	SELECT *, ROW_NUMBER()OVER(Partition By carVendorKey Order By minRate) as rowNum  FROM CarResponse WHERE CarRequestKey = @carRequestKey and RequestType= @RequestType) as CR
	WHERE CR.rowNum=1
END
GO
