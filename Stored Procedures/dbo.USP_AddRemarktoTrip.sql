SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[USP_AddRemarktoTrip]  
(    
	@TripKey INT, 
	@RemarkFieldName NVARCHAR(80), 
	@RemarkFieldValue NVARCHAR(2000), 
	@TripTypeKey SMALLINT, 
	@RemarksDesc NVARCHAR(2000), 
	@GeneratedType SMALLINT, 
	@CreatedOn DATETIME, 
	@Active BIT
)
AS 
    
BEGIN    
  
	INSERT INTO TripPNRRemarks(TripKey, RemarkFieldName, RemarkFieldValue,TripTypeKey, RemarksDesc, GeneratedType, CreatedOn, Active)
	VALUES(@TripKey, @RemarkFieldName, @RemarkFieldValue, @TripTypeKey, @RemarksDesc, @GeneratedType, @CreatedOn, @Active)

END    
  
GO
