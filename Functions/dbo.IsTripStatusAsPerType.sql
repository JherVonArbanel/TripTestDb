SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

--sp_helptext IsTripStatusAsPerType

  
CREATE FUNCTION [dbo].[IsTripStatusAsPerType](@TripStatusKey Int, @TripType nvarchar(30) )    
RETURNS BIT AS     
 BEGIN    
     
  DECLARE @Status BIT  = 0    
  IF @TripStatusKey <> 0    
  BEGIN       
   IF(Lower(@TripType)='currenttrips')    
   BEGIN    
     SET @Status =     
     CASE @TripStatusKey    
  WHEN (1)  --- Pending  
   THEN  1         
  WHEN (2)  --- Active or Purchase    
    THEN  1              
  --WHEN (4)  --- Booked    
   -- THEN  1    
  WHEN (5)  --- Cancelled    
   THEN  1          
  WHEN (7)  --- Held    
   THEN  1   
  WHEN (8) -- PENDING APPROVAL  
   THEN 1    
  WHEN (9) -- DENIED  
   THEN 1          
   WHEN (12) -- EXCHANGED
   THEN 1          
     END    
   END    
   ELSE IF(Lower(@TripType)='pasttrips')    
   BEGIN    
   BEGIN    
     SET @Status =     
     CASE @TripStatusKey          
      WHEN (3)  --- Traveled       
       THEN  1    
      --WHEN (4)  --- Booked    
      -- THEN  1    
      WHEN (5)  --- Cancelled    
       THEN  1    
      --WHEN (6)  --- Expired    
      -- THEN 1    
      --WHEN (7)  --- Held    
      -- THEN  1    
     END    
   END    
   END    
     ELSE IF(Lower(@TripType)='pasttripname')    
   BEGIN    
   BEGIN    
     SET @Status =     
     CASE @TripStatusKey          
      WHEN (3)  --- Traveled       
       THEN  1    
      --WHEN (4)  --- Booked    
      -- THEN  1    
      WHEN (5)  --- Cancelled    
       THEN  1    
      --WHEN (6)  --- Expired    
      -- THEN 1    
      --WHEN (7)  --- Held    
      -- THEN  1   
     END    
   END    
   END
   IF(Lower(@TripType)='currenttripname')    
   BEGIN    
     SET @Status =     
     CASE @TripStatusKey    
  WHEN (1)  --- Pending  
   THEN  1         
  WHEN (2)  --- Active or Purchase    
    THEN  1              
  --WHEN (4)  --- Booked    
   -- THEN  1    
  WHEN (5)  --- Cancelled    
   THEN  1          
  WHEN (7)  --- Held    
   THEN  1   
  WHEN (8) -- PENDING APPROVAL  
   THEN 1    
  WHEN (9) -- DENIED  
   THEN 1          
   WHEN (12) -- EXCHANGED
   THEN 1          
     END    
   END    
   ELSE IF(Lower(@TripType)='savedtrips')    
   BEGIN    
   BEGIN    
     SET @Status =     
     CASE @TripStatusKey    
      WHEN (1)  --- Pending or Saved    
       THEN  1          
     END    
   END    
   END    
  END    
  ELSE     
  BEGIN    
   SET @Status = 1    
  END    
  RETURN isnull(@Status,0)     
    
END

GO
