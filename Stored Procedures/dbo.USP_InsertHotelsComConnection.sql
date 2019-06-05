SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE Procedure [dbo].[USP_InsertHotelsComConnection]
(
	@cid		varchar(50) = '484760'
	, @apiKey	varchar(50) = '56fl9a31rm6kqp888op21hnifs'
	, @sig		varchar(50) = '9t0sk5qeguo7a'
	, @CERTorPRODUCTION varchar(15) = 'production'
)
AS  
BEGIN  

	DECLARE @connectionId INT

	IF lower(@CERTorPRODUCTION) = 'production'
	BEGIN
		SET @connectionId = 8
	END
	ELSE
	BEGIN
		SET @connectionId = 3
	END

	----------- Backup Existing PROD 
	INSERT INTO HotelsComConnection(cid, apiKey, sig, environment, test)
	SELECT cid, apiKey, sig, environment, test FROM HotelsComConnection WHERE connectionID = @connectionId

	----------- Update New credential 
	UPDATE HotelsComConnection 
	SET cid			= @cid
		, apiKey	= @apiKey 
		, sig		= @sig
	WHERE connectionID = @connectionId

END 
GO
