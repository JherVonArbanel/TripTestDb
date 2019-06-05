SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[USP_BulkInsertAirResponseAlternateDate]
	@airReponsesAlternateDate [TVP_AirResponseAlternateDate] READONLY
AS
BEGIN
	INSERT INTO [dbo].[AirResponseAlternateDate]
           ([airSubRequestKey]
           ,[airResponseAlternateDateKey]
           ,[airResponseAlternateDateOriginDate]
           ,[airResponseAlternateDateReturnDate]
           ,[airResponseAlternateDateAirlineCode]
           ,[airResponseAlternateDatePriceTotal])
	SELECT [airSubRequestKey]
           ,[airResponseAlternateDateKey]
           ,[airResponseAlternateDateOriginDate]
           ,[airResponseAlternateDateReturnDate]
           ,[airResponseAlternateDateAirlineCode]
           ,[airResponseAlternateDatePriceTotal]
	FROM @airReponsesAlternateDate 
END
GO
