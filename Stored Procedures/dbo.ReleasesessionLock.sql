SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ReleasesessionLock]
@ConnectionID int
AS 
Begin
		Delete from  sessionLock
		Where ConnectionID =@ConnectionID
	
end
GO
