SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[usp_DeletePassengerinfoForTrips]

@TripKey int,
@TripRequestKey int
AS

Update  TripPassengerInfo  Set Active = 0 Where TripKey = @TripKey and TripRequestKey = @TripRequestKey 
Update  TripPassengerCreditCardInfo Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerAirPreference Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerAirVendorPreference Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerCarPreference Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerCarVendorPreference  Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerHotelPreference  Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerHotelVendorPreference  Set Active = 0 Where TripKey = @TripKey
Update  TripPassengerUDIDInfo Set Active = 0 Where TripKey = @TripKey
Update TripPolicyException Set Active = 0 Where TripKey = @TripKey
Update TripAirSegmentOptionalServices Set isDeleted  = 1 Where TripKey = @TripKey
GO
