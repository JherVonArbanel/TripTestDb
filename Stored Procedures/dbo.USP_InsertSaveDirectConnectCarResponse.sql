SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Author,,Varun>
-- Create date: <Create Date,27Dec2011,>
-- Description:	<Description,Insert in CarResponse table ,>
-- =============================================
CREATE PROCEDURE  [dbo].[USP_InsertSaveDirectConnectCarResponse]
 @carResponseKey  uniqueidentifier,
 @carRequestKey int,
 @carVendorKey varchar(50),
 @supplierId varchar(50),
 @carCategoryCode varchar(50),
 @carLocationCode varchar(50),
 @carLocationCategoryCode varchar(50),
 @minRate float,
 @DailyRate float,
 @TotalChargeAmt float,
 @NoOfDays int
 
 
 
 
 

 
AS
BEGIN
 
INSERT INTO CarResponse ( carResponseKey,carRequestKey,carVendorKey,supplierId,carCategoryCode,carLocationCode,carLocationCategoryCode,minRate,DailyRate,TotalChargeAmt,NoOfDays ) VALUES
( @carResponseKey,@carRequestKey,@carVendorKey,@supplierId,@carCategoryCode,@carLocationCode,@carLocationCategoryCode,@minRate,@DailyRate,@TotalChargeAmt,@NoOfDays)select carResponseKey from CarResponse where carRequestKey = @carRequestKey AND carVendorKey = @carVendorKey
 	 
END
GO
