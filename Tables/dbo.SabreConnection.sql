CREATE TABLE [dbo].[SabreConnection]
(
[ConnectionID] [int] NOT NULL IDENTITY(1, 1),
[UserName] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Password] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[URL] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IPCC] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Domain] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FromPartyID] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ToPartyID] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MessageID] [nvarchar] (4000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinimumSession] [int] NULL,
[MaximumSession] [int] NULL,
[DefaultSessionTimeOut] [int] NULL,
[ActulSessionTimeOut] [int] NULL,
[DefaultConnection] [bit] NULL CONSTRAINT [DF__SabreConn__Defau__019E3B86] DEFAULT ((1)),
[restAPIUserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[restAPISecret] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[restAPIbase64String] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Deletes] ON [dbo].[SabreConnection] AFTER DELETE
AS 
BEGIN
		INSERT INTO LOG.dbo.Triggered_SabreConnection ([HOST_NAME], [Status], Action_Date, ConnectionID, UserName, [Password]
				, [URL], IPCC, Domain, FromPartyID, ToPartyID, MessageID, MinimumSession, MaximumSession
				, DefaultSessionTimeOut, ActulSessionTimeOut, DefaultConnection, restAPIUserID, restAPISecret
				, restAPIbase64String)
		SELECT	HOST_NAME(), 'Deleted', GETDATE(), ConnectionID, UserName, [Password]
				, [URL], IPCC, Domain, FromPartyID, ToPartyID, MessageID, MinimumSession, MaximumSession
				, DefaultSessionTimeOut, ActulSessionTimeOut, DefaultConnection, restAPIUserID, restAPISecret
				, restAPIbase64String
		FROM deleted
END
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[Updates] ON [dbo].[SabreConnection] AFTER UPDATE
AS 
BEGIN

	DECLARE @ColumnNames NVARCHAR(MAX) = ''
	
	IF UPDATE(UserName)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'UserName, '
	END

	IF UPDATE(Password)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'Password, '
	END

	IF UPDATE(URL)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'URL, '
	END

	IF UPDATE(IPCC)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'IPCC, '
	END

	IF UPDATE(Domain)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'Domain, '
	END

	IF UPDATE(FromPartyID)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'FromPartyID, '
	END

	IF UPDATE(ToPartyID)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'ToPartyID, '
	END

	IF UPDATE(MessageID)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'MessageID, '
	END

	IF UPDATE(MinimumSession)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'MinimumSession, '
	END

	IF UPDATE(MaximumSession)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'MaximumSession, '
	END

	IF UPDATE(DefaultSessionTimeOut)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'DefaultSessionTimeOut, '
	END

	IF UPDATE(ActulSessionTimeOut)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'ActulSessionTimeOut, '
	END

	IF UPDATE(DefaultConnection)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'DefaultConnection, '
	END

	IF UPDATE(restAPIUserID)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'restAPIUserID, '
	END

	IF UPDATE(restAPISecret)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'restAPISecret, '
	END

	IF UPDATE(restAPIbase64String)
	BEGIN
		SET @ColumnNames = @ColumnNames + 'restAPIbase64String, '
	END

	SET @ColumnNames = SUBSTRING(@ColumnNames, 1, LEN(@ColumnNames)-1)
	
	INSERT INTO LOG.dbo.Triggered_SabreConnection ( [HOST_NAME], [Status]
			, Action_Date, ConnectionID, UserName, [Password], [URL], IPCC, Domain
			, FromPartyID, ToPartyID, MessageID, MinimumSession, MaximumSession, DefaultSessionTimeOut
			, ActulSessionTimeOut, DefaultConnection, restAPIUserID, restAPISecret, restAPIbase64String)
	SELECT	HOST_NAME(), 'Updated Columns - ' + @ColumnNames + '.  [Rows here is OLD Value and you can find new value in Trip..SabreConnection table].'
			, GETDATE(),ConnectionID,UserName,[Password],[URL],IPCC,Domain
			,FromPartyID,ToPartyID,MessageID,MinimumSession,MaximumSession,DefaultSessionTimeOut
			,ActulSessionTimeOut,DefaultConnection,restAPIUserID,restAPISecret,restAPIbase64String
	FROM deleted

END
GO
ALTER TABLE [dbo].[SabreConnection] ADD CONSTRAINT [PK_SabreConnection] PRIMARY KEY CLUSTERED  ([ConnectionID]) ON [PRIMARY]
GO
