SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ravindra Kocharekar>
-- Create date: <23rd Jun 17>
-- Description:	<To Insert the Session Token for Sabre Rest api>
-- Execution: <Exec [dbo].[SabreRestSession_Insert] 'Test'>
-- =============================================
CREATE PROCEDURE [dbo].[SabreRestSession_Insert]
	-- Add the parameters for the stored procedure here
	@SessionToken nvarchar(max),
	@isCert bit,
	@connectionKey int=0
AS
BEGIN
	Insert into SabreRestSession (SessionToken,isCert,ConnectionID) 
		values(@SessionToken,@isCert,@connectionKey)
	
END
GO
