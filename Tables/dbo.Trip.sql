CREATE TABLE [dbo].[Trip]
(
[tripKey] [int] NOT NULL IDENTITY(1, 1),
[tripName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[userKey] [int] NULL,
[recordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[startDate] [datetime] NULL,
[endDate] [datetime] NULL,
[tripStatusKey] [int] NOT NULL,
[tripSavedKey] [uniqueidentifier] NULL,
[tripPurchasedKey] [uniqueidentifier] NULL,
[agencyKey] [int] NOT NULL,
[tripComponentType] [smallint] NULL,
[tripRequestKey] [int] NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF__Trip__CreatedDat__4D94879B] DEFAULT (getdate()),
[meetingCodeKey] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[deniedReason] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[siteKey] [int] NULL,
[isBid] [bit] NULL,
[isOnlineBooking] [bit] NOT NULL CONSTRAINT [DF__Trip__isOnlineBo__6BEEF189] DEFAULT ((1)),
[tripAdultsCount] [int] NULL,
[tripSeniorsCount] [int] NULL,
[tripChildCount] [int] NULL,
[tripInfantCount] [int] NULL,
[tripYouthCount] [int] NULL,
[noOfTotalTraveler] [int] NULL,
[noOfRooms] [int] NULL,
[noOfCars] [int] NULL,
[PurchaseComponentType] [int] NULL,
[tripTotalBaseCost] [float] NULL,
[tripTotalTaxCost] [float] NULL,
[ModifiedDateTime] [datetime] NULL,
[IsWatching] [bit] NULL CONSTRAINT [DF__Trip__IsWatching__627A95E8] DEFAULT ((0)),
[tripOriginalTotalBaseCost] [float] NULL,
[tripOriginalTotalTaxCost] [float] NULL,
[tripInfantWithSeatCount] [int] NULL,
[passiveRecordLocator] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isAudit] [bit] NULL,
[bookingCharges] [float] NULL CONSTRAINT [DF__Trip__bookingCha__12E8C319] DEFAULT (NULL),
[ISSUEDATE] [datetime] NULL,
[privacyType] [int] NULL CONSTRAINT [DF__Trip__privacyTyp__61DB776A] DEFAULT ((1)),
[DestinationSmallImageURL] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowersCount] [int] NULL,
[tripCreationPath] [int] NULL CONSTRAINT [DF__Trip__tripCreati__3B80C458] DEFAULT ((0)),
[isUserCreatedSavedTrip] [bit] NULL CONSTRAINT [DF__Trip__isUserCrea__47E69B3D] DEFAULT ((0)),
[CrowdCount] [bigint] NULL,
[TrackingLogID] [int] NULL,
[bookingFeeARC] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsHotelCrowdSavings] [bit] NULL CONSTRAINT [DF__Trip__IsHotelCro__4EE89E87] DEFAULT ((0)),
[SabreCreationDate] [datetime] NULL,
[promoId] [int] NULL,
[cashRewardId] [int] NULL,
[HostUserId] [int] NULL CONSTRAINT [DF__Trip__HostUserId__77B5A9F0] DEFAULT ((0)),
[RetainOrReplace] [datetime] NULL,
[groupKey] [int] NULL CONSTRAINT [DF__Trip__groupKey__21ABE3BC] DEFAULT ((0)),
[cancellationflag] [int] NULL CONSTRAINT [DF__Trip__cancellati__33CA93F7] DEFAULT ((0)),
[IsShowMyPic] [int] NOT NULL CONSTRAINT [DF__Trip__IsShowMyPi__114071C9] DEFAULT ((1)),
[UserIPAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionId] [varchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventKey] [int] NULL,
[AttendeeGuid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DestinationImageData] [image] NULL,
[HomeAirport] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FollowerCanVeiwMyPic] [int] NOT NULL CONSTRAINT [DF__Trip__FollowerCa__357DD23F] DEFAULT ((1)),
[subsiteKey] [int] NULL,
[isArrangerBookForGuest] [bit] NULL,
[FailureReason] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Culture] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isGroupBooking] [bit] NULL,
[AncillaryServices] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AncillaryFees] [float] NULL,
[referenceKey] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApprovalStatus] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Approver] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApprovalReason] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRequestApproval] [bit] NULL,
[ApproverEmailAddresses] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsRequestNotification] [bit] NULL,
[NotificationEmailAddresses] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ApprovalReasons] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NotificationReasons] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BackupApproverEmails] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripSavedReferenceId] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdvantageNumber] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CartNumber] [nvarchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsEmailSend_Require] [bit] NULL CONSTRAINT [DF__Trip__IsEmailSen__33A076C5] DEFAULT ((0)),
[DKNumber] [nvarchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[isUpgradeBooking] [tinyint] NULL,
[cross_reference_trip_id] [int] NULL,
[type] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__Trip__type__33015847] DEFAULT ('real')
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Gopal
-- Create date: 06-May-2016
-- Description:	Trip id caching after insert
-- =============================================
CREATE TRIGGER [dbo].[TRG_InsertTrip] ON [dbo].[Trip]
   AFTER INSERT
AS 
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @siteKey INT, @tripKey INT
	
	SELECT @siteKey = sitekey, @tripKey = tripKey FROM inserted 
	
	IF @siteKey = 39
	BEGIN
	
		UPDATE T 
		SET T.GroupKey = G.groupKey 
		FROM Trip T 
			INNER JOIN Vault..[GroupMembers] G ON T.userKey = G.groupMemberTableKey 
		WHERE T.tripKey = @tripKey -- T.siteKey = @siteKey And (T.groupKey is null OR T.groupKey = '' Or T.groupKey = 0)

	END

END
GO
ALTER TABLE [dbo].[Trip] ADD CONSTRAINT [pk_TripKey] PRIMARY KEY CLUSTERED  ([tripKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_agencyKey] ON [dbo].[Trip] ([agencyKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ng_idx_set3_Join6_set5_Join6_Trip_Meetingcodekey] ON [dbo].[Trip] ([meetingCodeKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_activeTrips_RecordLocator_SiteKey] ON [dbo].[Trip] ([recordLocator], [siteKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_myTrips_RecordLocator_SiteKey_UserKey] ON [dbo].[Trip] ([recordLocator], [siteKey], [userKey] DESC) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_COMP] ON [dbo].[Trip] ([recordLocator], [tripKey], [EventKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SiteKey_tripKey_Status_Purchased_MeetingCodeKey] ON [dbo].[Trip] ([siteKey]) INCLUDE ([meetingCodeKey], [tripKey], [tripPurchasedKey], [tripStatusKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_trip_siteKey_tripStatusKey] ON [dbo].[Trip] ([siteKey], [tripStatusKey]) INCLUDE ([CreatedDate], [endDate], [startDate], [tripKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NX_CI_SiteKey_TripStatusKey] ON [dbo].[Trip] ([siteKey], [tripStatusKey]) INCLUDE ([meetingCodeKey], [recordLocator], [startDate], [tripKey], [tripPurchasedKey], [tripSavedKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Trip_SiteKey_TripstatusKey] ON [dbo].[Trip] ([siteKey], [tripStatusKey]) INCLUDE ([tripKey], [tripSavedKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_pastTrips_RecordLocator_SiteKey_UserKey] ON [dbo].[Trip] ([startDate] DESC, [recordLocator], [siteKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Trip_StartDate_tripstatusKey_tripsavedKey] ON [dbo].[Trip] ([startDate], [tripStatusKey], [tripSavedKey]) INCLUDE ([tripAdultsCount], [tripChildCount], [tripKey], [tripRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_RNR_Trip_GET_TripKey_TripStatusKey] ON [dbo].[Trip] ([tripKey] DESC, [tripStatusKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IND_tripPurchasedKey] ON [dbo].[Trip] ([tripPurchasedKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_Req_Status] ON [dbo].[Trip] ([tripRequestKey], [tripStatusKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripSaved] ON [dbo].[Trip] ([tripSavedKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_tripStatusKey] ON [dbo].[Trip] ([tripStatusKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_For_MyTrips_tripStatusKey_GroupKey_tripKey_recordlocator_siteKey_UserKey] ON [dbo].[Trip] ([tripStatusKey], [groupKey], [tripKey], [recordLocator], [siteKey], [userKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_For_ActiveTrips_tripStatusKey_GroupKey_tripKey_StartDate_recordlocator_siteKey] ON [dbo].[Trip] ([tripStatusKey], [groupKey], [tripKey], [startDate] DESC, [recordLocator], [siteKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_userKey] ON [dbo].[Trip] ([tripStatusKey], [userKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_isUserCreatedSavedTrip] ON [dbo].[Trip] ([userKey], [isUserCreatedSavedTrip], [tripSavedKey], [IsWatching], [siteKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_userKey_siteKey] ON [dbo].[Trip] ([userKey], [siteKey], [tripTotalBaseCost], [tripTotalTaxCost]) INCLUDE ([CreatedDate], [DestinationSmallImageURL], [endDate], [startDate], [tripComponentType], [tripKey], [tripRequestKey], [tripSavedKey], [tripStatusKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_PurchasedSaved] ON [dbo].[Trip] ([userKey], [tripSavedKey], [tripPurchasedKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Trip_UserKey_TripStatusKey] ON [dbo].[Trip] ([userKey], [tripStatusKey]) ON [PRIMARY]
GO
