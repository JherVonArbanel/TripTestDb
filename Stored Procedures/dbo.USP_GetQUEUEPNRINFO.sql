SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/*USP_GetQUEUEPNRINFO 7 */
CREATE PROCEDURE [dbo].[USP_GetQUEUEPNRINFO]

@SiteKey INT

AS
	SELECT 
		QI.QueueKey,
		QI.QueueNumber,
		QI.QueueDescription,
		QI.GDSkey,
		QI.PCC,
		Isnull(QI.IsTravelFocus,0) as IsTravelFocus
	FROM QUEUEINFO QI 
			WHERE QI.ACTIVE= 1 
			AND QI.SiteKey = @SiteKey
			ORDER BY QI.QUEUENUMBER
			
	SELECT 
		QI.QueueKey,
		QI.QueueNumber,
		QI.QueueDescription,
		QI.GDSkey,
		QI.PCC,
		QH.QueuePNRHistoryKey,
		QH.LastAccessDatetime,
		QH.FirstRecordLocator,
		QH.FirstRecordLocatorPosition,
		QH.LastRecordLocator,
		QH.LastRecordLocatorPosition,
		QH.QueueKey
	FROM QUEUEINFO QI 
			inner JOIN QUEUEPNRHISTORY QH ON  QI.QUEUEKEY = QH.QUEUEKEY  AND QI.ACTIVE= 1 AND QH.ACTIVE=1
		WHERE QI.SiteKey = @SiteKey
		ORDER BY QI.QUEUENUMBER
		


GO
