SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================          
-- Author:  <Samir Dedhia>          
-- Create date: <22-Aug-2013>          
-- Description: <To get trip component type as per Page specified>          
-- =============================================          
-- SELECT  * FROM dbo.udf_GetTripComponentType (1,'FlightOnly')
CREATE FUNCTION [dbo].[udf_GetTripComponentType_Orignal]        
(          
 -- Add the parameters for the function here          
 @tripComponentType INT
 
)          
RETURNS           
@TripComponentTable TABLE           
(          
 TripComponentType INT,          
 TripComponentText VARCHAR(200)          
)          
AS          
BEGIN          
	
	DECLARE @tmpComponent TABLE 
	(
		 tripComponentType INT,          
		 tripComponentText VARCHAR(200)          
	)
	           
	INSERT INTO @tmpComponent
	VALUES
	(
		1, 'Air'
	)
	INSERT INTO @tmpComponent
	VALUES
	(
		2, 'Car'
	)
	INSERT INTO @tmpComponent
	VALUES
	(
		4, 'Hotel'
	)

	
	INSERT INTO @TripComponentTable
	SELECT * FROM @tmpComponent
	WHERE tripComponentType & @tripComponentType > 0
	
	
	
	RETURN 
           
END
GO
