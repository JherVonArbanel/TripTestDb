SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROCEDURE [dbo].[usp_AssignCreditCards]           
(             
 @meetingCode varchar(50),          
 @emailAddress varchar(100),        
 @siteKey int,      
 @companyID int,      
 @userKey int      
 )            
AS           
BEGIN           
      
DECLARE @IS_DISPLAY_CC_DROPDOWN INT      
DECLARE @IS_DISPLAY_GHOST_USERS INT      
DECLARE @STR_ASSIGNED_CARDS VARCHAR(2000)      
       
SELECT @IS_DISPLAY_CC_DROPDOWN = CASE WHEN COUNT(MA.meetingCodeKey) >= 1 THEN 1 ELSE 0 END FROM MeetingAttendees MA          
LEFT OUTER JOIN Meeting MT ON MT.meetingCodeKey = MA.MeetingCodeKey AND siteKey = @siteKey          
WHERE MA.EmailAddress = @emailAddress AND MA.MeetingCode = @meetingCode          
      
SELECT @IS_DISPLAY_GHOST_USERS = CASE WHEN COUNT(GCU.CreditCardKey) >= 1 THEN 1 ELSE 0 END FROM GhostCardUsers GCU      
LEFT OUTER JOIN CreditCard CC ON CC.creditCardKey = GCU.CreditCardKey AND CC.companyKey = @companyID      
WHERE GCU.EmailAddress = @emailAddress AND CC.isRestrictGhostCard = 1      
      
SET @STR_ASSIGNED_CARDS = 'SELECT creditCardKey,creditCardDescription,creditCardName FROM CreditCard INNER JOIN Address ON CreditCard.billingAddresskey = Address.addressKey WHERE IsDeleted = 0 AND companyKey = ' + CAST(@companyID AS VARCHAR(100)) + ' AND creditCarduserKey = ' + CAST(@userKey AS VARCHAR(100))      
/* If User is exists in Meeting White List */      
IF(@IS_DISPLAY_CC_DROPDOWN = 1)      
BEGIN      
  IF @STR_ASSIGNED_CARDS <> ''      
  BEGIN    
   SET @STR_ASSIGNED_CARDS = @STR_ASSIGNED_CARDS + '  UNION ALL SELECT creditCardKey,creditCardDescription,creditCardName FROM CreditCard WHERE isGhostCard = 1 AND isnull(isRestrictGhostCard,0) = 0 AND IsDeleted = 0 AND companyKey = ' + CAST(@companyID AS
  
 VARCHAR(100))       
  END    
  ELSE       
  BEGIN    
   SET @STR_ASSIGNED_CARDS = ' SELECT creditCardKey,creditCardDescription,creditCardName FROM CreditCard INNER JOIN Address ON CreditCard.billingAddresskey = Address.addressKey WHERE isGhostCard = 1 AND isnull(isRestrictGhostCard,0) = 0 AND IsDeleted = 0 AND companyKey = ' + CAST(@companyID AS VARCHAR(100))       
  END    
      
  IF EXISTS (SELECT * FROM Meeting WHERE meetingCode = @meetingCode AND ISNULL(meetingGhostCardKey,0) <> 0)    
  BEGIN    
  IF @STR_ASSIGNED_CARDS <> ''      
  BEGIN    
   SET @STR_ASSIGNED_CARDS = @STR_ASSIGNED_CARDS + ' AND creditCardKey IN (SELECT meetingGhostCardKey FROM Meeting WHERE meetingCode = ''' + @meetingCode + ''')'    
  END    
  END    
END      
      
/* If User exists in Restricted Ghost Card List */      
IF(@IS_DISPLAY_GHOST_USERS = 1)      
 BEGIN      
  IF @STR_ASSIGNED_CARDS <> ''     
  BEGIN     
   SET @STR_ASSIGNED_CARDS = @STR_ASSIGNED_CARDS + ' UNION ALL SELECT creditCardKey,creditCardDescription,creditCardName FROM CreditCard where isGhostCard = 1 AND IsDeleted = 0 AND isRestrictGhostCard = 1 AND companyKey = ' + CAST(@companyID AS VARCHAR(100)) + '  AND  creditCardKey in (select creditCardKey from GhostCardUsers where EmailAddress = ''' +  @emailAddress + ''')'       
  END    
  ELSE      
  BEGIN    
   SET @STR_ASSIGNED_CARDS = ' SELECT creditCardKey,creditCardDescription,creditCardName FROM CreditCard INNER JOIN Address ON CreditCard.billingAddresskey = Address.addressKey where isGhostCard = 1 AND IsDeleted = 0 AND isRestrictGhostCard = 1 AND companyKey = ' + CAST(@companyID AS VARCHAR(100)) + '  AND  creditCardKey in (
select creditCardKey from GhostCardUsers where EmailAddress = ''' +  @emailAddress + ''')'       
  END      
END        
EXEC(@STR_ASSIGNED_CARDS)      
             
END
GO
