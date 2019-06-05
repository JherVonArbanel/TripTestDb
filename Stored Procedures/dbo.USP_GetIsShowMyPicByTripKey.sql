SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <Create Date 28,12,2016>
-- Description:	<Description,, To Get the isshowMyPic value from trip table>
-- =============================================
CREATE PROCEDURE [dbo].[USP_GetIsShowMyPicByTripKey]
	-- Add the parameters for the stored procedure here
	@tripKey bigint    
	
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IsShowMyPic,FollowerCanVeiwMyPic FROM TRIP..Trip
	WHERE TRIPKEY=@tripKey
	
END
GO
