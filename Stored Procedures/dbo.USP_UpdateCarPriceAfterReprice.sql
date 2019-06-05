SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
 
CREATE PROCEDURE [dbo].[USP_UpdateCarPriceAfterReprice]
(
@carResponseKey uniqueidentifier, 
@minRate float,
@minRateteTax float,
@carCategoryCode varchar(50),
@creationDate DATETIME
)
AS 
BEGIN
UPDATE TripCarResponse
SET minRate = @minRate,
	minRateTax = @minRateteTax,
	carCategoryCode = @carCategoryCode,
	creationDate = @creationDate
WHERE carResponseKey = @carResponseKey
END
GO
