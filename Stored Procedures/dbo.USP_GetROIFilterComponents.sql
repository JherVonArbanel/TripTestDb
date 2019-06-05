SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [dbo].[USP_GetROIFilterComponents]    
@UserKey int ,    
@clientId Bigint 

AS        
BEGIN    
 --Declare @tmpClientID table      
 --(ClientID int)      
 --Insert into @tmpClientID(ClientID)  (select REPLACE(String,'''','') from AI.dbo.ufn_CSVToTable(@ClientID))    
    
    
 --select     
 -- Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,Prepaid_Travel,     Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets     
 --from tblROIUserFilter rf    
 --INNER JOIN   @tmpClientID  c on rf.CompanyKey = c.ClientID     
    
    
 --select     
 -- Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,Prepaid_Travel,     Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets     
 --from AI..tblROIUserFilter WHERE UserKey = @UserKey    
 
  select     
  Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,Prepaid_Travel,					Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets     
 from tblROIUserFilter rf    WHERE UserKey = @UserKey and CompanyKey = @clientId 
 
 
END
GO
