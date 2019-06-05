SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Pradeep Gupta>
-- Create date: <26-July-2016>
-- Description:	<To Get all sub-hash tag rule according to steve excel file.>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetSubHashTagRuleData]
	-- Add the parameters for the stored procedure here
	@pageno int = 0,
	@categorykey int = 0
AS
BEGIN
	select HashTagOrder from trip..SubHashTagRule where PageNo = @pageno and HashTagCategoryKey = @categorykey
END
GO
