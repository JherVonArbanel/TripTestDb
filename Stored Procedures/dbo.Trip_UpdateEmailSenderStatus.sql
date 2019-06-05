SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[Trip_UpdateEmailSenderStatus] 
( 
	@tripKey int,
	@isEmailSend bit
) 
AS

begin		
	    UPDATE Trip SET IsEmailSend_Require = @isEmailSend where tripKey = @tripKey 

	--IF @isEmailSend=0
	--BEGIN
		UPDATE TripEmailProcessing 
		SET LastModifiedDate=Getdate(),
		Status=0 
		WHERE  tripKey = @tripKey
	--END
end
GO
