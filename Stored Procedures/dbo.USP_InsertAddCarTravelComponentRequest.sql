SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,Insert in CarRequest table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_InsertAddCarTravelComponentRequest]
 @pickupCityCode  varchar(50),
 @dropoffCityCode varchar(3) ,
 @pickupDate datetime,
 @dropoffDate datetime,
 @carRequestCreated datetime
 
 
 
 
AS
BEGIN
 
INSERT INTO CarRequest ( pickupCityCode,dropoffCityCode, pickupDate, dropoffDate, carRequestCreated )VALUES ( @pickupCityCode,@dropoffCityCode, @pickupDate, @dropoffDate, @carRequestCreated   ) SELECT Scope_Identity()
 	 
END
GO
