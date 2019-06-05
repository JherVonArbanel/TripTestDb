SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,INSERT INTO TripRequest_hotel table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_SaveUserSpecificHotelRequest]

@tripRequestKey int ,
@hotelRequestKey int,
@noOfGuests int

AS
BEGIN
 
INSERT INTO TripRequest_hotel (tripRequestKey , hotelRequestKey , noOfGuests )VALUES(@tripRequestKey ,@hotelRequestKey ,@noOfGuests )


END
GO
