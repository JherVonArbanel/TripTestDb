SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,SELECT HotelRequest table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_GetCachedHotelRequest]


AS
BEGIN
 
SELECT  hotelRequestKey  hotelRequestCreated  FROM   HotelRequest

END
GO
