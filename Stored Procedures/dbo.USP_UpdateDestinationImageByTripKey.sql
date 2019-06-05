SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Rohita Patel>
-- Create date: <Create Date 06,03,2017>
-- Description:	<Description,, Update the trip binary destination image data>
-- =============================================
CREATE PROCEDURE [dbo].[USP_UpdateDestinationImageByTripKey]
	-- Add the parameters for the stored procedure here
	@tripKey bigint,
	@destinationImageUrl VARCHAR(1000),
	@destinationImageData Image=NULL
	
	
AS
BEGIN
	
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Update statements for procedure here
    IF @destinationImageData IS NOT NULL
		UPDATE Trip..Trip
		SET DestinationImageData=@destinationImageData,
			DestinationSmallImageURL=@destinationImageUrl
		WHERE tripKey=@tripKey  		
	
		
	select @@ROWCOUNT as UpdatedRow
	
	SET NOCOUNT OFF   
	
END
GO
