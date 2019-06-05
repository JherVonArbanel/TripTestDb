SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetSessionLock]
@connectionID int
AS 
Begin
		
		Select * from sessionLock where ConnectionID=@connectionID
end
GO
