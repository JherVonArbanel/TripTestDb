SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[usp_IsValidAirResponsesAvailableByRequestId] 
@airRequestKey INT 
AS 
BEGIN
	DECLARE @IsValidBFM Bit = 1
	Select   dbo.ufn_ValidateIsSucessfullBFM(@airRequestKey)  as IsValidBFM 
  
END
GO
