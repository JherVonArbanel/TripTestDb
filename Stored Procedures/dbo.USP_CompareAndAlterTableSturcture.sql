SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Jayant Guru
-- Create date: 12th Dec 2013
-- Description:	This SP compares two table (source and destination) structures 
--				and finds if any columns are missing in destination table.
--				Then it alters the destination table and adds the missing column.
-- =============================================
CREATE PROCEDURE [dbo].[USP_CompareAndAlterTableSturcture] 
	
	@SourceTableName VARCHAR(100)
	,@DestinationTableName VARCHAR(100)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TblSource AS TABLE 
    (
		ColumnName VARCHAR(200)
		,DataType VARCHAR(50)
		,MaxLength INT
	)
	
	DECLARE @TblDestination AS TABLE 
	(
		ColumnName VARCHAR(200)
		,DataType VARCHAR(50)
		,MaxLength INT
	)
	
	DECLARE @TblMissingColumn AS TABLE 
	(	
		ColumnName VARCHAR(200)
	)
	
	DECLARE @TblMissingColumnDetails AS TABLE 
	(
		MissingColumnId INT IDENTITY(1,1)
		,ColumnName VARCHAR(200)
		,DataType VARCHAR(50)
		,MaxLength INT
		,IsCreated Bit Default(0)
	)

	DECLARE @CountToExecute INT = 0
			,@AlterCount INT = 1
			,@ColumnName VARCHAR(150)
			,@DataType VARCHAR(50)
			,@MaxLength VARCHAR(10)
			,@SQL VARCHAR(4000)
			,@MissingColumnId INT
	
	/*INSERT SOURCE TABLE COLUMN*/
	INSERT INTO @TblSource (ColumnName, DataType, MaxLength)
	SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH 
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @SourceTableName
	
	/*INSERT DESTINATION TABLE COLUMN*/
	INSERT INTO @TblDestination (ColumnName, DataType, MaxLength)
	SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_NAME = @DestinationTableName
	
	/*FIND THE MISSING COLUMNS OF DESTINATION TABLE*/
	INSERT INTO @TblMissingColumn(ColumnName)
	SELECT ColumnName FROM @TblSource
	EXCEPT
	SELECT ColumnName FROM @TblDestination

	SET @CountToExecute = (SELECT COUNT(ColumnName) FROM @TblMissingColumn)
	
	/*IF ANY COLUMN IS MISSING IN DESTINATION TABLE THEN ADD THE COLUMN*/	
	IF (@CountToExecute > 0)
	BEGIN
		/*INSERT DETAILS OF MISSING COLUMN*/
		INSERT INTO @TblMissingColumnDetails (ColumnName, DataType, MaxLength)
		SELECT ColumnName, DataType, MaxLength
		FROM @TblSource
		WHERE ColumnName
		IN (SELECT ColumnName FROM @TblMissingColumn)
		
		/*LOOP TO ADD EACH MISSING COLUMN*/
		WHILE (@AlterCount <= @CountToExecute)
		BEGIN
			SELECT TOP 1 @MissingColumnId = MissingColumnId
			,@ColumnName = ColumnName
			,@DataType = DataType
			,@MaxLength = ISNULL(MaxLength,'')
			FROM @TblMissingColumnDetails
			WHERE IsCreated = 0
			
			IF(@MaxLength = 0)
			BEGIN
				SET @MaxLength = ''
			END
			ELSE IF(@MaxLength <> '')
			BEGIN
				SET @MaxLength = '(' + @MaxLength + ')'
			END
			
			SET @SQL = 'ALTER TABLE ' + @DestinationTableName + ' ADD '  + @ColumnName + ' ' + @DataType + ' ' + @MaxLength
						
			EXEC (@SQL)
			
			UPDATE @TblMissingColumnDetails SET IsCreated = 1 WHERE MissingColumnId = @MissingColumnId
			SET @AlterCount += 1
		END
	END

END
GO
