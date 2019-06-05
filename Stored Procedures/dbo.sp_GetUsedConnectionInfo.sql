SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetUsedConnectionInfo]
@ConnectionID int = 0 
as 
 
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
 
BEGIN TRANSACTION;



DECLARE @AVAILCONNECTION INT
DECLARE @TOTALCONNECTION INT

EXEC sp_getapplock @Resource = 'InsertSession', 
               @LockMode = 'Exclusive',@LockOwner = 'Transaction';
if(@ConnectionID > 0 )
BEGIN
	SET @AVAILCONNECTION = (SELECT COUNT(SessionID) FROM SabreSession WHERE ConnectionID =@ConnectionID and  UPPER(Status) = 'AVAILABLE') 
	SET @TOTALCONNECTION = (SELECT COUNT(SessionID) FROM SabreSession  WHERE ConnectionID =@ConnectionID )
	
END
ELSE
BEGIN
	SET @AVAILCONNECTION = (SELECT COUNT(SessionID) FROM SabreSession WHERE UPPER(Status) = 'AVAILABLE') 
	SET @TOTALCONNECTION = (SELECT COUNT(SessionID) FROM SabreSession)
	
END
SELECT   @AVAILCONNECTION AS AvailableConnection, @TOTALCONNECTION AS  TotalConnection

EXEC sp_releaseapplock @Resource = 'InsertSession';	
COMMIT TRANSACTION;
GO
