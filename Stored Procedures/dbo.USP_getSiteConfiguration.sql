SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[USP_getSiteConfiguration]      
 @siteUrl  VARCHAR(100),      
 @siteCode  VARCHAR(100)      
AS      
BEGIN      
      
 /* Declaration */      
      
 DECLARE  @isiteKey INT      
 SET  @isiteKey = 0      
      
 /* Get Site Key */      
       
 --if (@siteCode = '' OR @siteCode is null)      
       
 --BEGIN      
       
 -- SELECT @isiteKey = SC.siteKey      
       
 -- FROM [SiteConfiguration] SC WITH(NOLOCK)      
       
 -- INNER JOIN Subsite S WITH(NOLOCK) ON SC.sitekey = S.siteConfigurationKey      
       
 -- WHERE subsiteUrl= @siteUrl      
       
 --END      
       
 --ELSE      
       
 --BEGIN      
       
 -- SELECT @isiteKey = SC.siteKey      
       
 -- FROM [SiteConfiguration] SC WITH(NOLOCK)      
       
 -- INNER JOIN Subsite S WITH(NOLOCK) ON SC.sitekey = S.siteConfigurationKey      
       
 -- WHERE SC.siteCode= @siteCode      
       
 --END      
       
 /* Getting Site Configuration */      
       
 IF  (@siteUrl != '' and @siteUrl is not null)      
 BEGIN      
       
  SET @siteUrl = REPLACE(@siteUrl,'http://','')      
       
  SET  @siteUrl = REPLACE(@siteUrl,'https://','')      
       
  SELECT SC.[siteKey]      
     ,CASE WHEN S.subsiteURL IS NOT NULL THEN S.subsiteURL ELSE SC.[siteName] END AS 'siteName'       
     ,SC.[defaultProductView]      
     ,SC.[theme]      
     ,SC.[isSabreAllowed]      
     ,SC.[isFarelogixAllowed]      
     ,SC.[isAmadeusAirAllowed]      
     ,SC.[isLoginMandatoryForBooking]      
     ,SC.[landingPageUrl]      
     ,SC.[allowedAirlines]      
     ,SC.[isCorporateSite]     
     ,SC.[isRestrictNonRefundable ]    
     ,SC.[defaultCompanyKey]      
     ,SC.[defaultCurrency]      
     ,SC.[isSabreHotelAllowed]      
     ,SC.[isHotelsComAllowed]      
     ,SC.[HotelsComContentType]      
     ,SC.[isAmadeusHotelAllowed]      
     ,SC.[isSabreCarAllowed]      
     ,SC.[isDirectCarAllowed]      
     ,SC.[IsAmadeusCarAllowed]      
     ,SC.[isTravelArrangerAllowed]      
     ,SC.[isFarelogixProfileAllowed]      
     ,SC.[isSabreProfileAllowed]      
     ,SC.[isAmadeusProfileAllowed]      
     ,SC.[farelogixConnectionKey]      
     ,SC.[AgencyKey]      
     ,SC.[isFarelogixPNRTransferAllowed]      
     ,SC.[isExpenseModuleAllowed]      
     ,SC.[isFlightAllowed]      
     ,SC.[isHotelAllowed]      
     ,SC.[isCarAllowed]      
     ,SC.[airlines]      
     ,SC.[supportNameSpace]      
     ,SC.[supportNotifiationEmailUsers]      
     ,SC.[passwordPolicy]      
     ,SC.[passwordErrorDescription]      
     ,SC.[IsAllowSelfRegister]      
     ,SC.[siteGoogleAnalyticID]      
     ,SC.[totalInvalidAttemptCount]      
     ,SC.[disableAccountMinutes]      
     ,SC.[USPseudoCityCode]      
     ,SC.[NonUSPseudoCityCode]      
     ,SC.[SiteContractCode]      
     ,SC.[masterPage]      
     ,SC.[isSortByTotalFare]      
     ,SC.[isDefinedFareBuckets]      
     ,SC.[environment]      
     ,SC.[isBundledMultiCity]      
     ,SC.[isOAGAirAllowed]      
     ,SC.[serviceFeeAmount]      
     ,SC.[amadeusConnectionKey]      
     ,SC.[robots]      
     ,CASE WHEN S.sitecode IS NOT NULL THEN S.sitecode ELSE SC.[siteCode] END AS 'siteCode'  
     ,SC.[isMeetingCodeAllowed]      
     ,SC.[LoginPageURL]      
     ,SC.[PingdomUptimeImageUrl]      
     ,SC.[PingdomResponsetimeImageUrl]      
     ,CASE WHEN S.Data IS NOT NULL THEN S.Data ELSE SC.[Data] END AS 'Data'      
     ,SC.[isWithoutLoginForBooking]      
     ,SC.[autoActivation]      
     ,SC.[smtpFromEmail]      
     ,SC.[IsStandaloneHotelAllowed]      
     ,SC.[IsStandaloneCarAllowed]      
     ,SC.[isSortByContractFare]      
     ,SC.[isSecondLevelProfileTransferOnly]      
     ,SC.[createPNRQueueNumber]      
     ,SC.[DKNumber]      
     ,SC.[ticketingPseudoCode]      
     ,SC.[ticketedQueue]      
     ,SC.[changedOrCancelledQueue]      
     ,SC.[rejectedQueue]      
     ,SC.[emailSenderQueue]      
     ,SC.[heldQueue]      
     ,SC.[seatRequestedQueue]      
     ,SC.[smtpToEmail]      
     ,SC.[marketPlace]      
     ,SC.[ConnectionID]      
     ,SC.[IsOLAPEnable]      
     ,SC.[BCCEmailAddress],S.subsiteURL      
     ,S.subSiteKey   
  FROM [SiteConfiguration] SC WITH(NOLOCK)      
   INNER JOIN Subsite S WITH(NOLOCK) ON SC.sitekey = S.siteConfigurationKey      
  WHERE subsiteUrl= 'smbdirect.test.aa.com'--@siteUrl      
       
 END      
 --ELSE      
 --BEGIN      
       
  -- SELECT SC.*,S.subsiteURL      
  -- FROM [SiteConfiguration] SC WITH(NOLOCK)      
  -- INNER JOIN Subsite S WITH(NOLOCK) ON SC.sitekey = S.siteConfigurationKey      
  -- WHERE SC.siteCode= @siteCode      
       
 --END      
      
END  
GO
