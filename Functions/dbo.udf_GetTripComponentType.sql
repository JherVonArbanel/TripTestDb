SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================        
-- Author:  <Samir Dedhia>        
-- Create date: <22-Aug-2013>        
-- Description: <To get trip component type as per Page specified>        
-- =============================================        
CREATE FUNCTION [dbo].[udf_GetTripComponentType]      
(        
 -- Add the parameters for the function here        
 @PageType INT,      
 @ComponentType VARCHAR(50)         
)        
RETURNS         
@TripComponentTable TABLE         
(        
 TripComponentType INT,        
 TripComponentText VARCHAR(200)        
)        
AS        
BEGIN        
         
 IF (@PageType = 1) -- HOME PAGE        
 BEGIN         
         
 IF (UPPER(@ComponentType) = 'PACKAGE5STAR' OR UPPER(@ComponentType) = 'PACKAGE4STAR' OR UPPER(@ComponentType) = 'PACKAGE3STAR' OR UPPER(@ComponentType) = 'PACKAGEANYSTAR')
 BEGIN       
        
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   4,        
   'Hotel'        
     )           
            
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   5,        
   'Air,Hotel'        
     )           
             
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   6,        
   'Car,Hotel'        
     )           
             
             
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   7,        
   'Air,Car,Hotel'        
     )           
          
            
 END      
 ELSE IF (UPPER(@ComponentType) = 'HOTELONLY5STAR' OR UPPER(@ComponentType) = 'HOTELONLY4STAR' OR UPPER(@ComponentType) = 'HOTELONLY3STAR')      
 BEGIN       
       
     INSERT INTO @TripComponentTable        
     (        
    TripComponentType,         
    TripComponentText           
     )        
     VALUES        
     (        
    4,        
    'Hotel'        
     )             
       
 END      
 ELSE IF (UPPER(@ComponentType) = 'FLIGHTONLY')      
 BEGIN       
        
     INSERT INTO @TripComponentTable        
     (        
  TripComponentType,         
  TripComponentText           
     )        
     VALUES        
     (        
  1,        
  'Air'        
     )              
 END  
 ELSE IF (UPPER(@ComponentType) = 'CARONLY')          
 BEGIN  
     INSERT INTO @TripComponentTable        
     (        
  TripComponentType,         
  TripComponentText           
     )        
     VALUES        
     (        
  2,        
  'Car'        
     )               
 END  
 ELSE IF (UPPER(@ComponentType) = 'HOTELONLY')          
 BEGIN  
     INSERT INTO @TripComponentTable        
     (        
  TripComponentType,         
  TripComponentText           
     )        
     VALUES        
     (        
  4,        
  'Hotel'        
     )               
 END   
 ELSE       
 BEGIN       
       
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   1,        
   'Air'        
     )        
          
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   3,        
   'Air,Car'        
     )         
/* THIS IS COMMENTED SINCE ON LOAD WE DONT REQUIRE ONLY HOTEL TO COME AS FIRST TMU's ...              
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   4,        
   'Hotel'        
     )           
*/            
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   5,       
   'Air,Hotel'        
     )           
           
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   6,        
   'Car,Hotel'        
     )           
             
     INSERT INTO @TripComponentTable        
     (        
   TripComponentType,         
   TripComponentText           
     )        
     VALUES        
     (        
   7,        
   'Air,Car,Hotel'        
     )           
      
       
 END         
         
           
 END -- END OF HOME PAGE        
         
         
         
 RETURN         
END
GO
