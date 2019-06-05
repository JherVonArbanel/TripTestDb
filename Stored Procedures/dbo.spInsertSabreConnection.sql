SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[spInsertSabreConnection] 
(
	@ConnectionID	INT,
	@UserName		NVARCHAR(64),
	@Password		NVARCHAR(64),
	@URL			NVARCHAR(256),
	@Ipcc			NVARCHAR(10),
	@Domain			NVARCHAR(64),
	@FromPartyId	NVARCHAR(128),
	@ToPartyId		NVARCHAR(128),
	@MessageId		NVARCHAR(128)
)
AS

	SET NOCOUNT ON

	INSERT INTO [SabreConnection] 
	(
		[ConnectionID],
		[UserName],
		[Password],
		[URL],
		[Ipcc],
		[Domain],
		[FromPartyId],
		[ToPartyId],
		[MessageId]
	) 
	VALUES 
	(
		@ConnectionID,
		@UserName,
		@Password,
		@URL,
		@Ipcc,
		@Domain,
		@FromPartyId,
		@ToPartyId,
		@MessageId
	)
GO
