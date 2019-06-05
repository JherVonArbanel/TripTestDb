SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Ashima Gupta
-- Create date: 6th March 2016
-- Description:	This procedusre is used to fetch auto complete data when user enters 3 numbers are added for Zip Code search
-- exec [usp_GetZipCodeAutoCompleteData] 501
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetZipCodeAutoCompleteData]
	@strSearchString int 
AS
BEGIN

SET NOCOUNT ON

SELECT ZipCodeComponents FROM Trip..AutoCompleteZipCodeFast WHERE SearchCode = @strSearchString

SET NOCOUNT OFF
		
END
GO
