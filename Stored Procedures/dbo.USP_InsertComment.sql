SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Anupam Patel
-- Create date: 12/May/2015
-- Description:	It is used to store comments in DB
-- =============================================
CREATE PROCEDURE [dbo].[USP_InsertComment]
	-- Add the parameters for the stored procedure here
	@userKey INT,
	@tripKey INT,
	@eventKey INT,
	@commentText nVarchar(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert Statements for Procedure here
	INSERT INTO Comments 
	(userKey,tripKey,eventKey,commentText,createdDate) 
	Values(@userKey,@tripKey,@eventKey,@commentText,GETDATE())
	
	SELECT ISNULL(CAST(scope_identity() AS INT),0)
	
END
GO
