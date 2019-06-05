SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

 
CREATE PROCEDURE [dbo].[USP_GetPreviousTripSavedDeals]                
(      
--declare      
 @selectedNightlyDeal varchar(50)  
)            
as 
--set @selectedNightlyDeal  = 1 
BEGIN 
declare @tripId INT 
declare @currentDate datetime 
SELECT  TOP 1 @tripId= tripkey ,@currentdate =dealSentDate  from NightlyDealProcess N inner join ( SELECT * FROM ufn_CSVSplitString (@selectedNightlyDeal)) D on N.nightlyDealProcessKey = d.String  
--Select @tripId  ,@currentDate 
DECLARE @deals as TABLE (selectedDate varchar(20) ,tripkey int, componentKey  int ,tripsaveddealKey varchar(50),isCurrentDeal bit) 
INSERT @deals 
select  convert(varchar(20), dealSentDate,103)selectedDate, tripKey,componentType ,MAX(tripsaveddealKey),0 from TripSavedDeals where tripKey = @tripId and dealSentDate is not null  and convert(varchar(20), dealSentDate,103) <  convert(varchar(20),@currentDate ,103) 
group by convert(varchar(20), dealSentDate,103) ,tripKey,componentType 
 
 UPDATE @deals set isCurrentDeal = 0 
 INSERT INTO @deals (selectedDate ,tripkey ,componentKey ,tripsaveddealKey ,isCurrentDeal ) 
  
 (select  convert(varchar(20), dealSentDate,103) ,tripkey,componentType,tripsaveddealKey,1  from TripSavedDeals where tripsaveddealKey in (select * from ufn_CSVSplitString (@selectedNightlyDeal)))
 
--select selectedDate as dealSentdate,tripkey,nightltdealProcessKey  from @deals 

 --select * from @deals 

SELECT tripkey,convert(datetime,selecteddate,103) as selecteddate,isCurrentDeal,
 SUBSTRING( 
 (
  SELECT ( ', ' + tripsaveddealKey)
  FROM @deals t2 
  WHERE t1.selectedDate = t2.selectedDate and t1.isCurrentDeal = t2.isCurrentDeal
  ORDER BY t1.selectedDate, t2.selectedDate
  FOR XML PATH('')
 ), 3, 1000) dealList 
FROM @deals t1
GROUP BY selectedDate,tripkey,isCurrentDeal
  END
GO
