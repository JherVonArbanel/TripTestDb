SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetConnectionInfo]
@ConnectionID int
as 
Begin
IF(@ConnectionID > 0 ) 
			BEGIN
			SELECT [ConnectionID]
				  ,[UserName]
				  ,[Password]
				  ,[URL]
				  ,[IPCC]
				  ,[Domain]
				  ,[FromPartyID]
				  ,[ToPartyID]
				  ,[MessageID]
				  ,[MinimumSession]
				  ,[MaximumSession]
				  ,[DefaultSessionTimeOut]
				  ,[ActulSessionTimeOut]
				  ,[DefaultConnection]
			  FROM [SabreConnection]
			  Where [ConnectionID]=@ConnectionID
			 End
ELSE 

		BEGIN
		SELECT [ConnectionID]
			  ,[UserName]
			  ,[Password]
			  ,[URL]
			  ,[IPCC]
			  ,[Domain]
			  ,[FromPartyID]
			  ,[ToPartyID]
			  ,[MessageID]
			  ,[MinimumSession]
			  ,[MaximumSession]
			  ,[DefaultSessionTimeOut]
			  ,[ActulSessionTimeOut]
			  ,[DefaultConnection]
		  FROM [SabreConnection]
		  Where [DefaultConnection] =1 
		 End
END
GO
