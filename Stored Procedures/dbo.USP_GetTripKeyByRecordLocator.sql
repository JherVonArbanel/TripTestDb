SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 4th August 2017
-- Description:	Converted Inline Query to SP
-- =============================================

CREATE PROCEDURE [dbo].[USP_GetTripKeyByRecordLocator]
	@recordLocator VARCHAR(50)
AS
BEGIN

	SET NOCOUNT ON;

    SELECT tripKey 
	FROM Trip WITH(NOLOCK)
	WHERE recordLocator = @recordLocator

END
GO
