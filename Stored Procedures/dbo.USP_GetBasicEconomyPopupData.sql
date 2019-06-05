SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Keyur Sheth
-- Create date: 19-12-2018
-- Description:	Get basic economy popup data
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetBasicEconomyPopupData]
	
AS
BEGIN	
	SET NOCOUNT ON;    
	SELECT [ID], [AirlineCode], [ComponentIcon], [ComponentText], [BasicText], [MainText] FROM BasicEconomyPopupData
END
GO
