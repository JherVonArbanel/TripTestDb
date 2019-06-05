SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Jayant Guru
-- Create date: 22 Feb 2014
-- Description:	Checks airline code, if airlline code is different then it retuns 1 else 0
-- =============================================
--SELECT dbo.udf_ComapreMultipleAirlines('AA,AA,AA,AA,AA,AA,AA,MM')
CREATE FUNCTION [dbo].[udf_ComapreMultipleAirlines]
(
	@airlineCodes VARCHAR(30)
)
RETURNS BIT
AS
BEGIN
	
	DECLARE @isMultipleAirline BIT
			,@airlineCodeCount INT
			,@incrementCount INT
			,@previousAirlineCode VARCHAR(5) = NULL
			,@currentAirlineCode VARCHAR(5)
			,@airlineCodeKey INT
			
	DECLARE @TblAirlineCode AS TABLE
	(
		AirlineCodeKey INT IDENTITY(1,1)
		,AirlineCode VARCHAR(10)
		,isChecked BIT DEFAULT(0)
	)
	
	INSERT INTO @TblAirlineCode (AirlineCode)
	SELECT * FROM vault.dbo.ufn_CSVToTable (@airlineCodes)
	
	SET @incrementCount = 1    
	SET @airlineCodeCount = (Select COUNT(AirlineCode) from @TblAirlineCode)
	
	WHILE (@incrementCount <= @airlineCodeCount)
	BEGIN
			
		SELECT TOP 1 @airlineCodeKey = AirlineCodeKey, @currentAirlineCode = AirlineCode 
		FROM @TblAirlineCode WHERE isChecked = 0
				
		IF(ISNULL(@previousAirlineCode,@currentAirlineCode) <> @currentAirlineCode)
		BEGIN			
			SET @isMultipleAirline = 1
			BREAK
		END
		ELSE
		BEGIN			
			SET @isMultipleAirline = 0
			SET @previousAirlineCode = @currentAirlineCode	
		END	
		
		UPDATE @TblAirlineCode SET isChecked = 1 WHERE AirlineCodeKey = @airlineCodeKey
		SET @incrementCount += 1
	END
		
	RETURN @isMultipleAirline;

END

GO
