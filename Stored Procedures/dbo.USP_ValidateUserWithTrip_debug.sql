SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
  
CREATE PROCEDURE [dbo].[USP_ValidateUserWithTrip_debug]  
(  
 @userKey BigInt,  
 @tripKey BigInt  
)  
AS  
BEGIN  
IF EXISTS (select 1 from vault..[UserProfile] where userkey=@userKey and  userRoles in (4,5,8,31))  
BEGIN
select '1'  
 SELECT   
  T.siteKey,  
  U.companyKey  
 FROM trip..trip T  
 INNER JOIN Vault..[USER] U ON T.userkey=U.userKey  
 WHERE tripkey=@tripKey  
END  
ELSE  
BEGIN  
select '2'
Declare @UserCompanyKey bigInt  
Declare @TripCompanyKey bigInt  
 SELECT   
  @UserCompanyKey=U.companyKey  
 FROM  Vault..[USER] U  
 WHERE U.userKey=@userKey  
  
 SELECT   
  @TripCompanyKey=U.companyKey  
 FROM trip..trip T  
 INNER JOIN Vault..[USER] U ON T.userkey=U.userKey  
 WHERE tripkey=@tripKey  
  
 IF @UserCompanyKey=@TripCompanyKey  
 BEGIN  
  SELECT   
   T.siteKey,  
   U.companyKey  
  FROM trip..trip T  
  INNER JOIN Vault..[USER] U ON T.userkey=U.userKey  
  WHERE tripkey=@tripKey  
 END  
 ELSE  
 BEGIN  
 select '3'
  SELECT 0 SiteKey, 0 CompanyKey  
 END  
END  
END
GO
