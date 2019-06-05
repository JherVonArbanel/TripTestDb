SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <Create Date 28,12,2016>
-- Description:	<Description,, To Get the isshowMyPic value from trip table>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateIsShowMyPic]
	-- Add the parameters for the stored procedure here
	@tripKey bigint,
	@isShowMyPic int,
	@followerCanViewMyPic int
	
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE TRIP..Trip
	SET IsShowMyPic=@isShowMyPic,
		FollowerCanVeiwMyPic=@followerCanViewMyPic
	WHERE Tripkey=@tripKey
	
END
GO
