SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE PROCEDURE [dbo].[USP_Get_TripSavedReferenceId_Random]
--declare 
@TripKey bigint=35162, 
@tripSavedReferenceId varchar(50) output
AS
BEGIN
 RepeatStep:  
	DECLARE @sq_CompanyProfileCode varchar(10);
	DECLARE @CompanyProfile_Start_Code varchar(10)='T-';


   --SELECT @sq_CompanyProfileCode=NEXT VALUE FOR CompanyProfileCode;

   --SELECT  @CompanyProfileCode = @CompanyProfile_Start_Code + '' + CAST(@sq_CompanyProfileCode AS VARCHAR(10)) 

    DECLARE @Random NVARCHAR(10) 
	DECLARE @Upper INT; 
	DECLARE @Lower INT
	DECLARE @serialnumber as NVARCHAR(MAX) 

	SET @Lower = 1
	SET @Upper = @TripKey
	SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0) 
	SET @serialnumber  =
	UPPER(
			CHAR(ASCII('a')+(ABS(CHECKSUM(NEWID()))%25)) + 
			CHAR(ASCII('A')+(ABS(CHECKSUM(NEWID()))%25))
		) +
	RIGHT('000000' + LTRIM(STR(@Random)),4)
	

    SET  @tripSavedReferenceId = @CompanyProfile_Start_Code + '' + CAST(@serialnumber AS VARCHAR(10)) 
 
    IF EXISTS (SELECT 1 FROM trip..trip where tripSavedReferenceId=@tripSavedReferenceId)
	BEGIN
		--select 'Already exists'
		GOTO RepeatStep
	END
	--ELSE
	--BEGIN
	--	select 'New value'
	--END

	--select @tripSavedReferenceId
END 

GO
