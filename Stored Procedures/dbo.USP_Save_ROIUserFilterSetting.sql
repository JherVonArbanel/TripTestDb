SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[USP_Save_ROIUserFilterSetting]      
@UserKey int,      
@CompanyKey varchar(100),      
@Policy_Opportunities bit,      
@Negotiated_Discounts bit,      
@Loyalty_Awards bit,      
@Payment_Rebate bit,      
@Online_Adoption bit,      
@Web_Fares bit,      
@Waiver_Favors bit,      
@Prepaid_Travel bit,      
@Audit_Searches bit,      
@Agency_Discount bit,      
@PreTrip_Approval bit,      
@Lost_Tickets bit,      
@Exchanges bit,      
@Refunds bit,      
@Voids bit,      
@Banked_Tickets bit,      
@IsActive bit = null      
      
AS      
BEGIN      
  
	Declare @user_key int   
	Set @user_key = @UserKey  
	CREATE TABLE #tmpClientID  
	(ClientID INT, UserKey int)  

	CREATE TABLE #tmpClientID2  
	(ClientID INT, UserKey int, RowId int)  

	INSERT INTO #tmpClientID (ClientID )  
	SELECT * FROM ai..ufn_CSVToTable ( @CompanyKey)   

	update #tmpClientID  set UserKey = @user_key  

	--select * from #tmpClientID  

	INSERT INTO #tmpClientID2 (ClientID , UserKey , RowId )  
	SELECT ClientID, UserKey,  ROW_NUMBER() OVER (ORDER BY ClientID asc ) 
	FROM #tmpClientID  

	DECLARE @Cnt int, @CompKey int, @RowCounter int  
	SET @Cnt = (SELECT COUNT(*) from #tmpClientID)  
	SET @RowCounter = 1  
	WHILE(@Cnt > 0)  
	BEGIN  
		SET @CompKey = (SELECT ClientID FROM #tmpClientID2 WHERE RowId = @RowCounter)
		
		IF NOT EXISTS(SELECT UserKey,CompanyKey FROM tblROIUserFilter WHERE UserKey = @UserKey and CompanyKey = @CompKey)  
		BEGIN
		INSERT INTO tblROIUserFilter
			(UserKey,CompanyKey,Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,    
			Prepaid_Travel,Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets,IsActive)     
			 
			VALUES (@UserKey,@CompKey,@Policy_Opportunities,@Negotiated_Discounts,@Loyalty_Awards,@Payment_Rebate,@Online_Adoption,@Web_Fares,      
			@Waiver_Favors,@Prepaid_Travel,@Audit_Searches,@Agency_Discount,@PreTrip_Approval,@Lost_Tickets,@Exchanges,@Refunds,@Voids,      
			@Banked_Tickets,@IsActive) 
		END 
		ELSE
		BEGIN
			DELETE FROM tblROIUserFilter WHERE UserKey = @UserKey and CompanyKey = @CompKey
			INSERT INTO tblROIUserFilter
			(UserKey,CompanyKey,Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,    
			Prepaid_Travel,Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets,IsActive)     
			 
			VALUES (@UserKey,@CompKey,@Policy_Opportunities,@Negotiated_Discounts,@Loyalty_Awards,@Payment_Rebate,@Online_Adoption,@Web_Fares,      
			@Waiver_Favors,@Prepaid_Travel,@Audit_Searches,@Agency_Discount,@PreTrip_Approval,@Lost_Tickets,@Exchanges,@Refunds,@Voids,      
			@Banked_Tickets,@IsActive)
		END
		SET @Cnt = @Cnt - 1 
		SET @RowCounter =  @RowCounter + 1 
	END  

	--INSERT INTO tblROIUserFilter      
	--(UserKey,Policy_Opportunities,Negotiated_Discounts,Loyalty_Awards,Payment_Rebate,Online_Adoption,Web_Fares,Waiver_Favors,      
	--Prepaid_Travel,Audit_Searches,Agency_Discount,PreTrip_Approval,Lost_Tickets,Exchanges,Refunds,Voids,Banked_Tickets,IsActive)      

	--VALUES (@UserKey,@Policy_Opportunities,@Negotiated_Discounts,@Loyalty_Awards,@Payment_Rebate,@Online_Adoption,@Web_Fares,      
	--@Waiver_Favors,@Prepaid_Travel,@Audit_Searches,@Agency_Discount,@PreTrip_Approval,@Lost_Tickets,@Exchanges,@Refunds,@Voids,      
	--@Banked_Tickets,@IsActive)     

	
  
  
END
GO
