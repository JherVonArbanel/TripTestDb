CREATE TABLE [dbo].[TripRequest_hotel]
(
[tripRequestKey] [int] NOT NULL,
[hotelRequestKey] [int] NOT NULL,
[noOfGuests] [int] NOT NULL,
[NoOFRequestSentToGDS] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Idx_hotelRequestKey] ON [dbo].[TripRequest_hotel] ([hotelRequestKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_hotelRequestKey] ON [dbo].[TripRequest_hotel] ([hotelRequestKey]) INCLUDE ([noOfGuests]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_TripRequestKey] ON [dbo].[TripRequest_hotel] ([tripRequestKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_INC_tripRequestKey] ON [dbo].[TripRequest_hotel] ([tripRequestKey], [hotelRequestKey]) INCLUDE ([noOfGuests]) ON [PRIMARY]
GO
