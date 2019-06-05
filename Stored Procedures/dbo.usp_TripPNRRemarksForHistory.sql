SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE proc [dbo].[usp_TripPNRRemarksForHistory]
@Pnr varchar(50),
@TripHistoryKey uniqueidentifier
AS


Insert into TripPNRRemarks(
TripKey,
RemarkFieldName,
RemarkFieldValue,
TripTypeKey,
RemarksDesc,
GeneratedType,
CreatedOn,
Active,
TripHistoryKey )
select 
0 as TripKey,
RemarkFieldName,
RemarkFieldValue,
TripTypeKey,
RemarksDesc,
GeneratedType,
CreatedOn,
Active,
@TripHistoryKey
From TripPNRRemarks 
Where TripKey in (select TripKey from Trip where recordLocator = @Pnr )
GO
