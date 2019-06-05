SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <09-June-17>
-- Description:	<To get hotel policy>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetHotelPolicyDescriptionByHotelResponseId] 
	-- Add the parameters for the stored procedure here
	@hotelResponseId	UNIQUEIDENTIFIER
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	
   SELECT top 1 CASE WHEN checkInInstruction IS Not NULL THEN 1 ELSE 0 END AS tOrder,* 
		FROM HotelDescription WHERE hotelResponseKey = @hotelResponseId order by 1 desc;
   
END
GO
