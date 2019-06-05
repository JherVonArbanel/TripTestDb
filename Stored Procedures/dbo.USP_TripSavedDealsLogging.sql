SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 5th April 2013
-- Description:	Logging Trip saved deals
-- =============================================
CREATE PROCEDURE [dbo].[USP_TripSavedDealsLogging]
	-- Add the parameters for the stored procedure here
	@TripKey INT = 0
	,@GroupId INT = 0
	,@ComponentType INT = 0
	,@ErrorMessage VARCHAR(2000) = ''
	,@ErrorStack VARCHAR(8000) = ''
	,@Remarks VARCHAR(2000) = ''
	,@Request XML = NULL
	,@Response XML = NULL
	,@InitiatedFrom VARCHAR(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	INSERT INTO TripSavedDealLog (TripKey, GroupId, ComponentType, ErrorMessage, ErrorStack, Remarks, Request, Response, InitiatedFrom)
	VALUES (@TripKey, @GroupId, @ComponentType, @ErrorMessage, @ErrorStack, @Remarks, @Request, @Response, @InitiatedFrom)
	
END
GO
