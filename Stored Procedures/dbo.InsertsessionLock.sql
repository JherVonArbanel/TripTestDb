SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[InsertsessionLock]
@ConnectionID int
AS 
Begin
		if((Select COUNT(1) from sessionLock   where ConnectionID = @ConnectionID ) = 0)
		begin
			Insert sessionLock(IsSessionLock,ConnectionID) values(1,@ConnectionID)
			select SCOPE_IDENTITY() 
		end
		else
		begin
			select 0
		end
end


GO
