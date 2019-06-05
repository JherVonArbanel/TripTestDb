CREATE TABLE [dbo].[TripRequestBlindBid]
(
[TripRequestBlindBidKey] [int] NOT NULL IDENTITY(1, 1),
[TripRequestKey] [int] NULL,
[TripKey] [int] NULL,
[TripComponentType] [int] NULL,
[AirRequestTypeKey] [int] NULL,
[IsInternationalTrip] [bit] NULL,
[ClassLevel] [int] NULL,
[DepartureAirport] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ArrivalAirport] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TripFromDate] [datetime] NULL,
[TripToDate] [datetime] NULL,
[AdultCount] [int] NULL CONSTRAINT [DF__TripReque__Adult__75435199] DEFAULT ((0)),
[SeniorCount] [int] NULL CONSTRAINT [DF__TripReque__Senio__7A0806B6] DEFAULT ((0)),
[ChildCount] [int] NULL CONSTRAINT [DF__TripReque__Child__7AFC2AEF] DEFAULT ((0)),
[InfantCount] [int] NULL CONSTRAINT [DF__TripReque__Infan__7BF04F28] DEFAULT ((0)),
[YouthCount] [int] NULL CONSTRAINT [DF__TripReque__Youth__7CE47361] DEFAULT ((0)),
[TotalTraveler] [int] NULL CONSTRAINT [DF__TripReque__Total__781FBE44] DEFAULT ((0)),
[TripSavedKey] [uniqueidentifier] NULL,
[NoOfDays] [int] NULL CONSTRAINT [DF__TripReque__NoOfD__7DD8979A] DEFAULT ((0)),
[NoOfRooms] [int] NULL CONSTRAINT [DF__TripReque__NoOfR__7913E27D] DEFAULT ((0)),
[StarRating] [float] NULL,
[NoOfCars] [int] NULL CONSTRAINT [DF__TripReque__NoOfC__772B9A0B] DEFAULT ((0)),
[IsSuccess] [bit] NULL CONSTRAINT [DF__TripReque__IsSuc__763775D2] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TripRequestBlindBid] ADD CONSTRAINT [PK__TripRequ__7449A6AD707E9C7C] PRIMARY KEY CLUSTERED  ([TripRequestBlindBidKey]) ON [PRIMARY]
GO
