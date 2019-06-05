SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 21-Nov-2012
-- Description:	Truncate all table of Viator2 DB
-- =============================================
CREATE PROCEDURE [dbo].[USP_TruncateViatorTables]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Truncate Table ViatorMerchantModelXMLData
	Truncate Table ProductItem
	Truncate Table AgeBands
	Truncate Table AgeBand
	Truncate Table ComparisonPrices
	Truncate Table ComparisonPrice
	Truncate Table ProductItemFeatured
	Truncate Table ProductItemDetail
	Truncate Table Location
	Truncate Table RequiredInfoQuestions
	Truncate Table Question
	Truncate Table URLList
	Truncate Table URL
	Truncate Table ReservationDetail
	Truncate Table BlockOutDates
	Truncate Table BlockOutRange
	Truncate Table Options
	Truncate Table [Option]
	Truncate Table LanguageServices
	Truncate Table TourActivityLanguage
	Truncate Table DateRange
	Truncate Table DayhashPricing
	Truncate Table Pricing
	Truncate Table InfantPrice
	Truncate Table ChildPrice
	Truncate Table YouthPrice
	Truncate Table AdultPrice
	Truncate Table SeniorPrice
	Truncate Table RecommendedInfantPrice
	Truncate Table RecommendedChildPrice
	Truncate Table RecommendedYouthPrice
	Truncate Table RecommendedAdultPrice
	Truncate Table RecommendedSeniorPrice

	
END
GO
