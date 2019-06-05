SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,SELECT from CarRequest table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetCachedCarRequest]
@pickupCityCode varchar(50),
@pickupDate datetime,
@dropoffDate datetime,
@carRequestCreated datetime

 
AS
BEGIN
 
SELECT  carRequestKey  carRequestCreated  FROM   CarRequest  WHERE pickupCityCode = @pickupCityCode AND dateadd(dd,0, datediff(dd,0,pickupDate)) = dateadd(dd,0, datediff(dd,0,@pickupDate)) AND dateadd(dd,0, datediff(dd,0,dropoffDate)) = dateadd(dd,0, datediff(dd,0,@dropoffDate)) and carRequestCreated > @carRequestCreated 	 
END
GO
