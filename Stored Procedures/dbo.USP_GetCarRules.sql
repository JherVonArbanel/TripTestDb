SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Richa>
-- Create date: <06/08/2012>
-- Description:	<Add the car rules for carResponseDetailsKey>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetCarRules]
	@carResponseDetailsKey uniqueidentifier
AS
BEGIN
	select carRules from CarResponseDetail 
	where carResponseDetailKey=@carResponseDetailsKey
END
GO
