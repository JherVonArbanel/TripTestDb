SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--exec USP_GetBrandName 1,'415756c5-f577-46bd-b317-f2aeaad8ac9e','00000000-0000-0000-0000-000000000000'
--exec USP_GetBrandName 1,'415756c5-f577-46bd-b317-f2aeaad8ac9e','16e53e01-b553-4251-bf96-e472024370bb'

--exec USP_GetBrandName 2,'d03aaeca-277b-4959-a7a7-7a2911af477e','00000000-0000-0000-0000-000000000000'
--exec USP_GetBrandName 2,'d03aaeca-277b-4959-a7a7-7a2911af477e','754dac7d-1baf-4809-a13d-cb40deab7a5d'

CREATE PROCEDURE [dbo].[USP_GetBrandName]

(
@LegNumber INT =0,
@responseid UNIQUEIDENTIFIER = null,
@multiBrandResponseKey UNIQUEIDENTIFIER = null
)
AS
BEGIN
IF (@multiBrandResponseKey IS NOT NULL AND @multiBrandResponseKey <> '{00000000-0000-0000-0000-000000000000}')  
	BEGIN  
		SELECT airlegBrandname FROM NormalizedAirResponsesMultiBrand WITH(NOLOCK)
		WHERE airresponseMultiBrandkey = @multiBrandResponseKey and airLegNumber =  @LegNumber 
	END 
	ELSE
	BEGIN
		SELECT airlegBrandname FROM NormalizedAirResponses WITH(NOLOCK)
		WHERE airresponsekey = @responseid and airLegNumber =  @LegNumber 
	END	
END
GO
