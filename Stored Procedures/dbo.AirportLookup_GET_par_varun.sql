SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AirportLookup_GET_par_varun](

	@prefixText			VARCHAR(100),
	@toGetCountryCode	INT = 0
)AS

BEGIN

Declare @myString Varchar(400)
Declare @sCount int
Declare @iCount int
Declare @spart varchar(200)	

		DECLARE @tblAirport as table(
				AirportName varchar(200),
				CityName varchar(200),
				StateCode varchar(50),
				CountryCode varchar(50),
				AirportCode varchar(50),
				AirPriority tinyint 
			)
			
	IF @toGetCountryCode = 0
	BEGIN		
		IF LEN(@prefixText)=3  
		BEGIN

			insert into @tblAirport SELECT 
				AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode,
				AirPriority 
			FROM AirportLookup 
			WHERE AirportCode = @prefixText
			insert into @tblAirport SELECT 
				AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode,
				AirPriority 
			FROM AirportLookup 
			WHERE AirportCode <> @prefixText and (CityName LIKE (@prefixText +'%'))and CityCode = @prefixText and AirStatus =0 order by AirPriority,Citycode,CityName asc
						
		
			SELECT 
				AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode,
				AirPriority 
			FROM @tblAirport 
		END
		ELSE
		BEGIN
			insert into @tblAirport SELECT 
				AirportName,
				CityName,
				StateCode,	
				CountryCode,
				AirportCode,
				AirPriority 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ('%'+ @prefixText +'%')) and AirStatus =0 order by AirPriority asc
			if (select COUNT(*) from @tblAirport) = 0
			begin
				set @myString = @prefixText
				Select @iCount = charindex(' ',@myString,0)
				if @iCount > 0
				begin
					set @sCount = 1
					While @sCount > 0
					Begin
						if(@iCount > 0)
						begin
							Select @spart = substring(@myString,0,@iCount)	
							Select @myString = substring(@mystring,@iCount + 1,len(@myString) - @iCount)
						end
						else 
						begin
							set @spart = @myString
							set @myString = ''
						end
							insert into @tblAirport SELECT 
							AirportName,
							CityName,
							StateCode,
							CountryCode,
							AirportCode,
							AirPriority 
							FROM AirportLookup 
							WHERE (AirportName LIKE (case @sCount when 1 then (@spart +' %') else ('%' + @spart +'%') end) OR CityName LIKE (case @sCount when 1 then (@spart +' %') else ('%' + @spart +'%') end)) 
							and AirStatus =0 order by AirPriority asc
							Select @iCount = charindex(' ',@myString,0)		
							set @sCount = LEN(@myString)		
					end 
				end
			end
			select distinct AirportName,
				CityName,
				StateCode,
				CountryCode,
				AirportCode,AirPriority  from @tblAirport order by AirPriority asc
				
				Delete FROM @tblAirport
		END		
	END
	ELSE
	BEGIN
		IF LEN(@prefixText) = 3
		BEGIN
			SELECT CountryCode 
			FROM AirportLookup 
			WHERE AirportCode = @prefixText	--and (AirportName LIKE ('%'+ @prefixText +'%') OR CityName LIKE ( @prefixText +'%')) and AirStatus =0 order by AirPriority asc
		END
		ELSE
		BEGIN
			DECLARE @tblCountryCode as table(
				CountryCode varchar(50)	
			)
			insert into @tblCountryCode SELECT CountryCode 
			FROM AirportLookup 
			WHERE (AirportName LIKE ('%' + @prefixText + '%') OR CityName LIKE ('%'+ @prefixText +'%')) and AirStatus=0  order by AirPriority asc
			if (select COUNT(*) from @tblCountryCode) = 0
			begin
				set @myString = @prefixText
				Select @iCount = charindex(' ',@myString,0)
				if @iCount > 0
				begin
					set @sCount = 1
					While @sCount > 0
					Begin
						if(@iCount > 0)
						begin
							Select @spart = substring(@myString,0,@iCount)	
							Select @myString = substring(@mystring,@iCount + 1,len(@myString) - @iCount)
						end
						else 
						begin
							set @spart = @myString
							set @myString = ''
						end
							insert into @tblCountryCode SELECT 							
							CountryCode 
							FROM AirportLookup 							
							WHERE (AirportName LIKE (case @sCount when 1 then (@spart +' %') else ('%' + @spart +'%') end) OR CityName LIKE (case @sCount when 1 then (@spart +' %') else ('%' + @spart +'%') end))
							and AirStatus =0 order by AirPriority asc
							Select @iCount = charindex(' ',@myString,0)		
							set @sCount = LEN(@myString)		
					end 
				end
			end
			select distinct * from @tblCountryCode 
			
			Delete FROM @tblAirport
		END		
	END	
END
GO
