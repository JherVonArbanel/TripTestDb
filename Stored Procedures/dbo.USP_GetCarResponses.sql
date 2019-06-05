SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,SELECT View from CarRequest table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetCarResponses]
@CarRequestKey int

 
AS
BEGIN
 
SELECT * FROM vw_sabreCarResponse WHERE CarRequestKey = @CarRequestKey ORDER BY minRate
END
GO
