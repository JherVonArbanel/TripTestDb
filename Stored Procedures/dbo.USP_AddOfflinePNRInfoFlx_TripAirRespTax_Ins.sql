SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddOfflinePNRInfoFlx_TripAirRespTax_Ins]
(  
	@airResponseKey UNIQUEIDENTIFIER, 
	@amount			FLOAT, 
	@designator		NVARCHAR(50), 
	@nature			NVARCHAR(50), 
	@description	NVARCHAR(50)
)
AS  
BEGIN  

	INSERT INTO [tripAirResponseTax]([airResponseKey], [amount], [designator], [nature], [description]) 
	VALUES(@airResponseKey, @amount, @designator, @nature, @description)

END  

GO
