SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DeletesessionLock]
@ConnectionID int = 0 ,
@SessionLockID int = 0 

AS 
Begin

if(@ConnectionID > 0 )
BEGIN
		Delete from  sessionLock
		Where ConnectionID =@ConnectionID
	END
	ELSE if(@SessionLockID > 0 )
	
	BEGIN
	Delete from  sessionLock
		Where SessionLockID =@SessionLockID
	END
end
GO
