SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[SetIropManifest]
(
	@fk_IROPId int
	,@IROPRecordLocator varchar(50)
	, @FirstName varchar(50)
	, @MiddleName varchar(50)
	, @LastName varchar(50)
	, @Gender varchar(1)
	, @DateOfBirth datetime
	, @EmailAddress varchar(50)
	, @ContactPhoneNumber  varchar(50)
	, @DepartureCity varchar(3)
	, @ArrivalCity varchar(3)
	, @PAXConxInfo varchar(100)
	, @SSRCode varchar(100)
	, @SSRComments varchar(100)
	, @ClassOfService varchar(50)
	, @PriorityCode varchar(50)
)
AS
BEGIN
--select * from trip..tblIROP
--select * from trip..tblIROP_Manifest
INSERT INTO Trip..tblIROP_Manifest(fk_IROPId, IROPRecordLocator, FirstName, MiddleName, LastName, Gender, DateOfBirth, EmailAddress, ContactPhoneNumber, DepartureCity, ArrivalCity, PAXConxInfo, SSRCode, SSRComments, ClassOfService, PriorityCode)
VALUES(@fk_IROPId
	,@IROPRecordLocator
	, @FirstName
	, @MiddleName
	, @LastName
	, @Gender
	, @DateOfBirth
	, @EmailAddress
	, @ContactPhoneNumber
	, @DepartureCity
	, @ArrivalCity
	, @PAXConxInfo
	, @SSRCode
	, @SSRComments
	, @ClassOfService
	, @PriorityCode)

END
GO
