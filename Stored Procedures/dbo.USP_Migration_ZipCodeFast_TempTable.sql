SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		<Ashima gupta, Pradeep Gupta>
-- Create date: <6-mar-16>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[USP_Migration_ZipCodeFast_TempTable]
	
AS
BEGIN
	
	TRUNCATE TABLE Trip..AutoCompleteZipCodeFast_Temp
	
	Declare @displayText varchar(500)
	Declare @Cityname varchar(100)
	Declare @Citycode varchar(100)
	Declare @zipCode int
	Declare @JsonValue varchar(1000)
	DECLARE db_cursor CURSOR FOR SELECT CityCode,CityName,DisplayText,ZipCode FROM  trip..HotelAutoCompleteForZipCodeSearch_Temp 

	OPEN db_cursor   
	FETCH NEXT FROM db_cursor INTO @Citycode ,@Cityname ,@displayText ,@zipCode 

	WHILE @@FETCH_STATUS = 0   
	BEGIN   
		
		--set @JsonValue= null
		
		IF @Citycode is not null
		BEGIN
			SET @JsonValue ='"{\"components\":[{\"zipCode\":[{\"display\":\"'+@displayText + ' ['+@Citycode+']' +'\", \"cityName\":\"'+@Cityname+'\", \"friendlyName\":\"'+@Cityname+'\"}]}]}"'
		END
		
		--print @JsonValue
		INSERT INTO Trip..AutoCompleteZipCodeFast_Temp (SearchCode,ZipCodeComponents) VALUES(@zipCode,@JsonValue)
		
		FETCH NEXT FROM db_cursor INTO @Citycode ,@Cityname ,@displayText ,@zipCode 
	END   

	CLOSE db_cursor   
	DEALLOCATE db_cursor

	
END
GO
