SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create PROCEDURE [dbo].[usp_GetTripTicketspnr]
(
	@from datetime,
    @To datetime,
    @recordLocator varchar(50)
)
AS
BEGIN

	IF @from IS NOT NULL
	BEGIN
	
	
	
select TYPE='No of Booked PNRs - Booked' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='4')  and (t.CreatedDate between @from and @To)		
 
union all

 select TYPE='No of Pending PNRs - Pending' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='1')  and (t.CreatedDate between @from and @To)	
        
 union all
        		
select TYPE='No of Active PNRs - Active' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='2')  and (t.CreatedDate between @from and @To)	
 
 union all
 
select TYPE='No of Traveled PNRs - Traveled' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='3')  and (t.CreatedDate between @from and @To)	
 		
 union all

 select TYPE='No of Canceled PNRs - Canceled' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='5')  and (t.CreatedDate between @from and @To)	
        
 union all
        		
select TYPE='No of Expired PNRs - Expired' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='6')  and (t.CreatedDate between @from and @To)	

 union all

select TYPE='No of Held PNRs - Held' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='7')  and (t.CreatedDate between @from and @To)	
	END
	
	ELSE
	
	
	BEGIN
select TYPE='No of Booked PNRs - Booked' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='4')  		
 
union all

 select TYPE='No of Pending PNRs - Pending' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='1')  	
        
 union all
        		
select TYPE='No of Active PNRs - Active' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='2')  	
 
 union all
 
select TYPE='No of Traveled PNRs - Traveled' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='3')  
 		
 union all

 select TYPE='No of Canceled PNRs - Canceled' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='5')  
        
 union all
        		
select TYPE='No of Expired PNRs - Expired' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='6')  	

 union all

select TYPE='No of Held PNRs - Held' , CNT_Booked = COUNT(t.tripStatusKey)  from Trip t inner join Trip t1 on t.tripRequestKey=t1.tripRequestKey where t.recordLocator  =@recordLocator and  (t.tripStatusKey ='7')  
	END

END


GO
