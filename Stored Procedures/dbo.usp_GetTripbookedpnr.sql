SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_GetTripbookedpnr]
(
	@from datetime,
    @To datetime
)
AS
BEGIN

IF @from IS NOT NULL
	
select 
       CASE   
         when TripStatusKey = '1' Then 'No of Pending PNRs - Pending' 
         when TripStatusKey = '2' Then 'No of Active PNRs - Active' 
         when TripStatusKey = '3' Then 'No of Traveled PNRs - Traveled' 
         when TripStatusKey = '4' Then 'No of Booked PNRs - Booked'
         when TripStatusKey = '5' Then 'No of Canceled PNRs - Canceled' 
         when TripStatusKey = '6' Then 'No of Expired PNRs - Expired' 
         when TripStatusKey = '7' Then 'No of Held PNRs - Held' 
       END
          AS [TYPE],
         COUNT(tripStatusKey)as CNT_Booked        
         from Trip where CreatedDate between @from and @To group by tripStatusKey 
        
	ELSE

select 
       CASE   
         when TripStatusKey = '1' Then 'No of Pending PNRs - Pending' 
         when TripStatusKey = '2' Then 'No of Active PNRs - Active' 
         when TripStatusKey = '3' Then 'No of Traveled PNRs - Traveled' 
         when TripStatusKey = '4' Then 'No of Booked PNRs - Booked'
         when TripStatusKey = '5' Then 'No of Canceled PNRs - Canceled' 
         when TripStatusKey = '6' Then 'No of Expired PNRs - Expired' 
         when TripStatusKey = '7' Then 'No of Held PNRs - Held' 
       END
          AS [TYPE],
         COUNT(tripStatusKey)as CNT_Booked        
         from Trip group by tripStatusKey 
       
END
GO
