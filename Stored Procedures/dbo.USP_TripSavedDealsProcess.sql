SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [dbo].[USP_TripSavedDealsProcess]
	@NIGHTLYDEALPROCESSKEY	INT,
	@SAVING					DECIMAL(18,2),
	@TODAYPRICE				DECIMAL(18,2)
AS
BEGIN

	DECLARE @tableHTML  NVARCHAR(MAX);
	--DECLARE @NIGHTLYDEALPROCESSKEY	INT,
	--		@SAVING					DECIMAL(18,2),
	--		@TODAYPRICE				DECIMAL(18,2)
	
	SELECT	@NIGHTLYDEALPROCESSKEY = TripSavedDealKey, 
			@SAVING = (originalPerPersonPrice-currentPerPersonPrice), 
			@TODAYPRICE = currentPerPersonPrice
	FROM TripSavedDeals
	WHERE TRIPKEY IN (SELECT MAX(TRIPKEY) FROM NIGHTLYDEALPROCESS)

	--SET @tableHTML = 
	--	  N'<html><head><title>Save Trip Email</title></head>'
	--	+ N'<body><h2>Trip Easy</h2><h3>Today''s Price: '+ CONVERT(NVARCHAR, @TODAYPRICE) + '</h3>'
	--	+ N'<h4>'+ CONVERT(NVARCHAR, @Saving) + ' Savings</h4><a href="http://localhost:42600/travel/cart/SaveTrip?DealId='+ CONVERT(NVARCHAR, @NIGHTLYDEALPROCESSKEY) + '">Book Trip</a></body></html>' 

	--SET @tableHTML = 		
	--	    N'<html><body><div style="width:650px; margin:0px; padding:0px; border:1px solid green"><div align="center"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/email_bg.jpg" width="742" height="403" border="0" /><div style="width:230px; margin:-266px 0 0 325px; padding:0px; font-size:13px; text-align:left; font-family:Arial, Helvetica, sans-serif; border:1px solid green">'
	--	  + N'Today''s Price:<span style="font-size:18px; font-weight:bold;"> $' + CONVERT(NVARCHAR, @TODAYPRICE) + '</span> <br />      <span style="font-size:9px; color:#929292;">RT per person incl. taxes & fees</span> <br />      <span style="font-size:18px; font-weight:bold;">$'+ CONVERT(NVARCHAR, @Saving) + ' savings</span> </div>    <div align="center" style="margin:7px 0 0 210px; padding:0px;">'
	--	  + N'<a href="http://travelauction.rinira.in/travel/cart/SaveTrip?DealId='+ CONVERT(NVARCHAR, @NIGHTLYDEALPROCESSKEY) + '"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/btn_book_now.jpg" width="88" height="25" border="0" /></a></div></div></div></body></html>'
    
SET @tableHTML = 
'<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>Untitled Document</title>
</head>
<body>
<div style="width:742px; margin:0px; padding:0px;">
  <table width="100%" cellpadding="0" cellspacing="0" border="0">
    <tr>
      <td><div style="width:530px; margin:0px; padding:0px;"></div></td>
      <td><div style="width:200px; margin:0px; padding:0px;"></div></td>
    </tr>
    <tr>
      <td colspan="2"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/logo_header.jpg" width="742" height="74" border="0" /></td>
    </tr>
    <tr>
      <td align="left" style="vertical-align:top">
        <table width="533" cellpadding="0" cellspacing="0" border="0">
          <tr>
            <td><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/cont_left_top.jpg" width="365" height="123" border="0" /></td>
            <td style="vertical-align:top"><table width="168" cellpadding="0" cellspacing="0" border="0">
                <tr>
                  <td colspan="2" style="vertical-align:top"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/cont_right_top.jpg" width="168" height="57" border="0" /></td>
                </tr>
                <tr>
                  <td align="left" style="margin:0px; padding:0px; font-size:13px; text-align:left; font-family:Arial, Helvetica, sans-serif;">Today''s Price:<span style="font-size:18px; font-weight:bold;"> $' + CONVERT(NVARCHAR, @TODAYPRICE) + '</span> <br />
                    <span style="font-size:9px; color:#929292;">RT per person incl. taxes & fees</span> <br />
                    <span style="font-size:18px; font-weight:bold;">$'+ CONVERT(NVARCHAR, @Saving) + ' savings</span></td>
                  <td align="right" width="15"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/cont_right_top_right.jpg" width="15" height="66" border="0" /></td>
                </tr>
              </table></td>
          </tr>
          <tr>
            <td><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/cont_left_bottom.jpg" width="365" height="60" border="0" /></td>
            <td><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/cont_right_bottom.jpg" width="168" height="60" border="0" usemap="#Map" /></td>
          </tr>
        </table></td>
      </td>
      <td rowspan="2" align="right"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/right-size_banner.jpg" width="209" height="324" border="0" /></td>
    </tr>
    <tr>
      <td align="left"><img src="http://travelauction.rinira.in/App_Themes/Auction/Images/footer_banner.jpg" width="533" height="141" border="0" /></td>
    </tr>
  </table>
</div>

<map name="Map" id="Map"><area shape="rect" coords="16,4,112,34" href="http://travelauction.rinira.in/travel/cart/SaveTrip?DealId='+ CONVERT(NVARCHAR, @NIGHTLYDEALPROCESSKEY) + '" /></map></body>
</html>'

    
--	Select ID=@NIGHTLYDEALPROCESSKEY, Saving=@SAVING, TODAYPRICE=@TODAYPRICE,  @tableHTML 
	EXEC msdb..sp_send_dbmail @profile_name='GKProfile', @recipients='punit.shah@rinira.com',
		@copy_recipients='jayant.guru@rinira.com;abhosale@rinira.com,sunil.hunnolli@rinira.com', 
		@subject='TripEasy - Today''s Deal',
		@body = @tableHTML, 
		@body_format = 'HTML';

	--EXEC msdb..sp_send_dbmail @profile_name='GKProfile', @recipients='jverma@rinira.com',
	--	@copy_recipients='sunil.hunnolli@rinira.com;ngopal@rinira.com', 
	--	@subject='TripEasy - Today''s Deal',
	--	@body = @tableHTML, 
	--	@body_format = 'HTML';

END
	
--Select TOP 2 * from trip..Nightlydealprocess order by 1 Desc 
----SELECT * FROM sysmail_mailitems
----SELECT * FROM sysmail_sentitems
----SELECT * FROM sysmail_log
--?DealId=1,2,3
GO
