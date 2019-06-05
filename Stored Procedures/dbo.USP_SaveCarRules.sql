SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Richa Shah>
-- Create date: <06/08/2012>
-- Description:	<Add the car rules for carResponseDetailsKey>
-- =============================================
CREATE PROCEDURE [dbo].[USP_SaveCarRules]
 @carResponseDetailsKey uniqueidentifier,
 @carRules varchar(2000)
AS
BEGIN
	Update CarResponseDetail 
	set
	carRules=@carRules
	where carResponseDetailKey=@carResponseDetailsKey
	
END
GO
