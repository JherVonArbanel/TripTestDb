SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Keyur Sheth
-- Create date: 30 December 2014
-- Description:	This proc is used to update air response key in events table
-- =============================================
CREATE PROCEDURE [dbo].[usp_UpdateEventAirResponseKey]
	@eventKey BIGINT,
	@airResponseKey UNIQUEIDENTIFIER
AS
BEGIN
	UPDATE
		[Events]
	SET
		AirResponseKey = @airResponseKey
	WHERE
		eventKey = @eventKey
END
GO
