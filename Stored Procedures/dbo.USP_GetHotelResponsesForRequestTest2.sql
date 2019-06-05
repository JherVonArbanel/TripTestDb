SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_GetHotelResponsesForRequestTest2]
( @hotelRequestKey  int ,
  @sortField varchar(50)='',
  ---@hotelRatings varchar(200)='3,4,5',
   @hotelRatings varchar(200)='',
  @mindistance float = 0 ,
  @maxdistance float= 1000,
  @minPrice float=0.0 ,
  @maxPrice float=999999999.99,
  @hotelAmenities varchar(200)='', 
  @chainCode varchar(10) = 'ALL' ,
  @pageNo int ,
  @pageSize int ,
  @hotelName varchar(100) = '' 
 )
as

Declare @FirstRec int
Declare @LastRec int
Declare @sortColumn varchar(50)
Declare @sqlString varchar(2000)
Declare @shortString varchar(2000)

-- Initialize variables.
Set @FirstRec = (@pageNo  - 1) * @PageSize
Set @LastRec = (@pageNo  * @PageSize + 1)
 
if ( @mindistance > 0 ) 
begin
set @mindistance = @mindistance + 0.01
end 
 DECLARE @hotelResponseResult TABLE 
  (
		rowNum int IDENTITY(1,1) NOT NULL, 
		hotelResponseKey uniqueidentifier,
		supplierHotelKey varchar(50),
		hotelRequestKey int,
		supplierId varchar(50),
		minRate float,
		HotelName varchar(128),
		Rating int,
		RatingType varchar(50),
		ChainCode varchar(50),
		HotelId int,
		Latitude float,
		Longitude float,
		Address1 varchar(256),
		CityName varchar(64),
		StateCode varchar(2),
		CountryCode varchar(2),
		ZipCode varchar(16),
		PhoneNumber varchar(32),
		FaxNumber varchar(32),
		CityCode varchar(3),
		distance float,
		checkInDate datetime,
		checkOutDate datetime,
		HotelDescription varchar(8000),
		ChainName varchar(128),minRateTax float,
		ImageURL varchar(100),
		preferenceOrder int 
	
  )


		 IF @sortField <> ''
		 BEGIN
			IF @sortField = 'Hotel'
			   BEGIN
				 SET @sortColumn = 'HotelName'
			   END
			ELSE IF @sortField = 'Price'
			   BEGIN
				 SET @sortColumn = 'minRate'
			   END
			ELSE IF @sortField = 'distance'
			   BEGIN
				 SET @sortColumn = 'distance'
			   END		
			ELSE IF @sortField = 'Rating'
			   BEGIN
				 SET @sortColumn = 'Rating'
			   END			   	
		  END	
		  
		  
 IF @sortField = ''
	begin
		  		 
--SET @sqlString = 'SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + '''''' + ' and Rating in ( select * from ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' )) and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and ' +  CONVERT(varchar, @maxdistance) + (case when @chainCode <> 'ALL' then ' and chaincode =''' + @chainCode + '''' else '' end) + ' order by minRate,distance,Rating,HotelName asc'

SET @shortString = 'hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + '''''' + case when @hotelRatings <> '' then  ' and Rating in ( select * from vault.dbo.ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' ))'else '' end +  '  and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and ' +  CONVERT(varchar, @maxdistance) + (case when @chainCode <> 'ALL' then ' and chaincode =''' + @chainCode + '''' else '' end) + (case when  @hotelName <> '' then ' and replace([HotelName],'''''''','''') like ''' + @hotelName + '''' else '' end )

SET @sqlString = '(Select * from vw_hotelDetailedResponse1 where supplierId=''hotelsCom'' and hotelId Not in (Select HotelId from vw_hotelDetailedResponse1 where supplierId=''sabre'' and ' + @shortString + ') and ' + @shortString + ') Union all (Select * from vw_hotelDetailedResponse1 where  supplierId=''sabre''  and  ' + @shortString + ') order by minRate,distance,Rating,HotelName asc'

print(@sqlString) 

insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate, HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceOrder) 
EXEC(@sqlString)

--and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end 

SELECT * FROM @hotelResponseResult --where rowNum > @FirstRec  AND rowNum< @LastRec 
		 
		 end  
		  
		  

else if  @hotelAmenities='ALL'
begin 
		 
--SET @sqlString = 'SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + '''''' + ' and Rating in ( select * from ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' )) and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and ' +  CONVERT(varchar, @maxdistance) + (case when @chainCode <> 'ALL' then ' and chaincode =''' + @chainCode + '''' else '' end) +' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'

SET @shortString = 'hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + ''''''   + case when @hotelRatings <> '' then ' and Rating in ( select * from vault.dbo.ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' ))'else ''  end + ' and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and ' +  CONVERT(varchar, @maxdistance) + (case when @chainCode <> 'ALL' then ' and chaincode =''' + @chainCode + '''' else '' end)  + (case when  @hotelName <> '' then ' and replace([HotelName],'''''''','''') like ''' + @hotelName + '''' else '' end )

SET @sqlString = '(Select * from vw_hotelDetailedResponse1 where supplierId=''hotelsCom'' and hotelId Not in (Select HotelId from vw_hotelDetailedResponse1 where supplierId=''sabre'' and ' + @shortString + ') and ' + @shortString + ') Union all (Select * from vw_hotelDetailedResponse1 where  supplierId=''sabre''  and  ' + @shortString + ') order by ' + CONVERT(varchar, @sortColumn) + ' Asc'

insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceOrder) 
EXEC(@sqlString)

--and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end 

SELECT * FROM @hotelResponseResult --where rowNum > @FirstRec  AND rowNum< @LastRec 


--order by minRate


end 

else 
begin 

		 
--SET @sqlString = 'SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + '''''' + ' and Rating in ( select * from ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' )) and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and  ' +  CONVERT(varchar, @maxdistance) + (case when @chainCode <> 'ALL' then ' and chaincode =''' + @chainCode + '''' else '' end)+ ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'

SET @shortString = 'hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + '''''' + ' and Rating in ( select * from vault.dbo.ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' )) and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and  ' +  CONVERT(varchar, @maxdistance) + (case when @chainCode <> 'ALL' then ' and chaincode =''' + @chainCode + '''' else '' end)

SET @sqlString = '(Select * from vw_hotelDetailedResponse1 where supplierId=''hotelsCom'' and hotelId Not in (Select HotelId from vw_hotelDetailedResponse1 where supplierId=''sabre'' and ' + @shortString + ') and ' + @shortString + ') Union all (Select * from vw_hotelDetailedResponse1 where  supplierId=''sabre''  and  ' + @shortString + ')  order by ' + CONVERT(varchar, @sortColumn) + ' Asc'



--print @sqlString
insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL,preferenceOrder) 
EXEC(@sqlString)
--SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=@hotelRequestKey and HotelName <> '' and Rating in ( select * from ufn_CSVToTable ( @hotelRatings ))and  minRate between   @minPrice and  @maxPrice and distance between  @mindistance and @maxdistance  
 
 --case when @sortField='Hotel'
 --then HotelName
 -- when @sortField='Price' then  minRate 
 -- when @sortField='distance' then  distance     
 -- when @sortField='Rating' then   Rating end --and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end 

/* and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end  and HotelId 
in
(select distinct Hotelid from [HotelContent].[dbo].HotelAmenities where AmenityId in (select * from ufn_CSVToTable (@hotelAmenities) ) group by HotelId 
having
COUNT(hotelid)=( select COUNT(*) from ufn_CSVToTable ( @hotelAmenities)) 
)order by HotelId*/
SELECT * FROM @hotelResponseResult --where rowNum > @FirstRec  AND rowNum< @LastRec 


--order by minRate


end 
/*
if @sortField='Price'
begin 
insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL) 
SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=@hotelRequestKey and HotelName <> '' and Rating in ( select * from ufn_CSVToTable ( @hotelRatings ))and  minRate between   @minPrice and  @maxPrice and distance between  @mindistance and @maxdistance   and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end  and HotelId 
in
(select distinct Hotelid from [HotelContent].[dbo].HotelAmenities where AmenityId in (select * from ufn_CSVToTable (@hotelAmenities) ) group by HotelId 
having
COUNT(hotelid)=( select COUNT(*) from ufn_CSVToTable ( @hotelAmenities)) 
)order by HotelId
SELECT * FROM @hotelResponseResult where rowNum > @FirstRec  AND rowNum< @LastRec order by minRate desc
end

if @sortField='distance'
begin 
insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL) 
SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=@hotelRequestKey and HotelName <> '' and Rating in ( select * from ufn_CSVToTable ( @hotelRatings ))and  minRate between   @minPrice and  @maxPrice and distance between  @mindistance and @maxdistance   and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end  and HotelId 
in
(select distinct Hotelid from [HotelContent].[dbo].HotelAmenities where AmenityId in (select * from ufn_CSVToTable (@hotelAmenities) ) group by HotelId 
having
COUNT(hotelid)=( select COUNT(*) from ufn_CSVToTable ( @hotelAmenities)) 
)order by HotelId
SELECT * FROM @hotelResponseResult where rowNum > @FirstRec  AND rowNum< @LastRec order by distance desc
end



if @sortField='Rating'
begin 
insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL) 
SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=@hotelRequestKey and HotelName <> '' and Rating in ( select * from ufn_CSVToTable ( @hotelRatings ))and  minRate between   @minPrice and  @maxPrice and distance between  @mindistance and @maxdistance   and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end  and HotelId 
in
(select distinct Hotelid from [HotelContent].[dbo].HotelAmenities where AmenityId in (select * from ufn_CSVToTable (@hotelAmenities) ) group by HotelId 
having
COUNT(hotelid)=( select COUNT(*) from ufn_CSVToTable ( @hotelAmenities)) 
)order by HotelId
SELECT * FROM @hotelResponseResult where rowNum > @FirstRec  AND rowNum< @LastRec order by Rating desc
end


if @sortField='Hotel'
begin 
insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL) 
SELECT * FROM vw_hotelDetailedResponse1 where  hotelRequestKey=@hotelRequestKey and HotelName <> '' and Rating in ( select * from ufn_CSVToTable ( @hotelRatings ))and  minRate between   @minPrice and  @maxPrice and distance between  @mindistance and @maxdistance   and ChainCode = case when @chainCode ='' then ChainCode else @chainCode end  and HotelId 
in
(select distinct Hotelid from [HotelContent].[dbo].HotelAmenities where AmenityId in (select * from ufn_CSVToTable (@hotelAmenities) ) group by HotelId 
having
COUNT(hotelid)=( select COUNT(*) from ufn_CSVToTable ( @hotelAmenities)) 
)order by HotelId
SELECT * FROM @hotelResponseResult where rowNum > @FirstRec  AND rowNum< @LastRec order by HotelName asc
end
*/





Select MIN (minRate)as LowestPrice ,MAX (minRate)as HighestPrice From vw_hotelDetailedResponse1 where  hotelRequestKey=@hotelRequestKey and HotelName <> ''

Select  Distinct MIN ( minRate) As BestPrice,Rating as Rating From  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey group by Rating order by Rating 

Select MIN (distance)as Minimumdistance ,MAX (distance)as Maximumdistance From  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey 


/***** Matrix for all brands as per distance ****/

 
 select min(minrate) as minRate ,chaincode ,ChainName, 0 as mindistance ,2 as Maxdistance,Rating  from  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey and Rating in ( select * from vault.dbo.ufn_CSVToTable ( @hotelRatings )) and distance between 0 and 2  group by chaincode ,chainname ,Rating 
   union 
   select min(minrate) as minRate  ,chaincode ,ChainName, 2 as mindistance ,5 as Maxdistance,Rating  from  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey and Rating in ( select * from vault.dbo.ufn_CSVToTable ( @hotelRatings )) and distance > 2 and distance <5   group by chaincode ,chainname  ,Rating
   union 
 select min(minrate) as minRate  ,chaincode ,ChainName, 5 as mindistance ,10 as Maxdistance ,Rating from  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey and Rating in ( select * from vault.dbo.ufn_CSVToTable ( @hotelRatings )) and   distance > 5   group by chaincode ,chainname  ,Rating
 
 select COUNT(*)as NoOfHotels,'0-2' as distance  from  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey and Rating in ( select * from vault.dbo.ufn_CSVToTable ( @hotelRatings )) and distance between 0 and 2  
 union
 select COUNT(*)as NoOfHotels,'2-5' as distance  from  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey and Rating in ( select * from vault.dbo.ufn_CSVToTable ( @hotelRatings )) and distance > 2 and distance <5
 union
 select COUNT(*)as NoOfHotels,'>5' as distance  from  vw_hotelDetailedResponse1 where hotelRequestKey=@hotelRequestKey and Rating in ( select * from vault.dbo.ufn_CSVToTable ( @hotelRatings )) and   distance > 5 
  
 select COUNT(*) as [TotalCount] from @hotelResponseResult 
 

 
 
 
 --print @hotelRequestKey 
 -- --@sortField varchar(50)='',
 -- --@hotelRatings varchar(200)='1,2,3,4,5,0',
 -- --@mindistance int = 0 ,
 -- --@maxdistance int= 1000,
 -- --@minPrice float=0.0 ,
 -- --@maxPrice float=999999999.99,
 -- --@hotelAmenities varchar(200)='', 
 -- --@chainCode varchar(10) = 'ALL' ,
 -- --@pageNo int ,
 -- --@pageSize int 
 
 --select * from @hotelResponseResult order by
 --case when @sortField='Hotel' then HotelName
 -- when @sortField='Price' then  minRate 
 -- when  @sortField='distance' then  distance     
 -- when @sortField='Rating' then   Rating end
 
 
 --SET @sqlString = 'SELECT * FROM  @hotelResponseResult'-- where  hotelRequestKey=' + CONVERT(varchar, @hotelRequestKey) + ' and HotelName <> ' + '''''' + ' and Rating in ( select * from ufn_CSVToTable ( ''' + CONVERT(varchar, @hotelRatings) + ''' )) and  minRate between  ' +  CONVERT(varchar, @minPrice) + ' and ' + CONVERT(varchar, @maxPrice) + ' and distance between ' +  CONVERT(varchar, @mindistance) + ' and ' +  CONVERT(varchar, @maxdistance) + ' order by ' + CONVERT(varchar, @sortColumn) + ' Asc'

--insert into @hotelResponseResult (hotelResponseKey,supplierHotelKey,hotelRequestKey,supplierId,minRate,HotelName,Rating,RatingType,ChainCode,HotelId,Latitude,Longitude,Address1,CityName,StateCode,CountryCode,ZipCode,PhoneNumber,FaxNumber,CityCode,distance,checkInDate,checkOutDate,HotelDescription,ChainName,minRateTax,ImageURL) 
 print(@sqlString)
 
 
 
 
 
 
 
/****** Matrix ends here *****/
GO
