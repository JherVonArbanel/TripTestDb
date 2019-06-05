SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_InsertDestinationFromDF] 
(	
@origin varchar(5),
@destinations varchar(2000)
)
AS
BEGIN
DECLARE @IntLocation INT
        WHILE (CHARINDEX(',',    @destinations, 0) > 0)
        BEGIN
              SET @IntLocation =   CHARINDEX(',',    @destinations, 0)      
              INSERT INTO Destination (Origin,Destination)
              --LTRIM and RTRIM to ensure blank spaces are   removed
              SELECT @origin,RTRIM(LTRIM(SUBSTRING(@destinations,   0, @IntLocation)))   
              SET @destinations = STUFF(@destinations,   1, @IntLocation,   '') 
        END
        INSERT INTO Destination (Origin,Destination)
        SELECT @origin,RTRIM(LTRIM(@destinations))--LTRIM and RTRIM to ensure blank spaces are removed
        RETURN
END
GO
