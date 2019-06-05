SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 22 December 2014
-- Description:	Procedure is used to update recommend flight flag in events table
-- =============================================
CREATE PROCEDURE [dbo].[usp_SaveRecommendedFlightStatus]	
	@eventKey BIGINT,
	@isRecommendFlight BIT
AS
BEGIN
	UPDATE 
		[Events]  
	SET 
		IsRecommendingFlight = @isRecommendFlight
	WHERE  
		eventKey = @eventKey  
END
GO
