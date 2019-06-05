SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Manoj Kumar Naik
-- Create date: 26-07-2016
-- Description:	Return AirVendorGroupName 
-- =============================================
CREATE FUNCTION [dbo].[udf_GetAirlineGroupName] 
(
	@MultipleAirlineCodes varchar(50)
)
RETURNS varchar(50)
AS
BEGIN
      
        DECLARE @AirlineCodes as Table 
	    (
		  airlineCode varchar(10)
		)
		
		DECLARE @GroupKeyTable as Table 
	    (
		   groupKey int
		)
		
	    DECLARE @isAirlineGroupAvailable bit	
	    DECLARE @AirlineGroupName varchar(50)	
	    DECLARE @RowCount int

        INSERT INTO @AirlineCodes  select * From ufn_CSVSplitString(@MultipleAirlineCodes) 

        INSERT INTO @GroupKeyTable  SELECT AirVendorLookup.AirVendorGroupKey FROM Trip..AirVendorLookup 
			                 INNER JOIN @AirlineCodes AC ON AC.airlineCode = AirVendorLookup.AirlineCode 
			                 GROUP BY AirVendorLookup.AirVendorGroupKey
  --      SELECT @isAirlineGroupAvailable = CAST(
		--	CASE WHEN EXISTS(SELECT AirVendorLookup.AirVendorGroupKey FROM Trip..AirVendorLookup 
		--	                 INNER JOIN @AirlineCodes AC ON AC.airlineCode = AirVendorLookup.AirlineCode 
		--	                 GROUP BY AirVendorLookup.AirVendorGroupKey 
		--	) THEN 1
		--	ELSE 0 
		--	 END 
		--AS BIT)         
		
	    SELECT @RowCount= @@ROWCOUNT 
	    
	    
	    IF @RowCount = 1
	    BEGIN
	      SET @isAirlineGroupAvailable=1
	    END
	    ELSE
	    BEGIN
	      SET @isAirlineGroupAvailable=0
	    END
	    
	    IF 	@isAirlineGroupAvailable = 1
		BEGIN
		
		SELECT TOP 1 @AirlineGroupName = AG.AirVendorGroupName FROM @AirlineCodes AC
		   INNER  JOIN Trip..AirVendorLookup AL ON AL.AirlineCode = AC.airlineCode
		   INNER  JOIN Trip..AirVendorGroup AG ON AG.AirVendorGroupKey = AL.AirVendorGroupKey
		END
		ELSE
		 BEGIN
		    SET @AirlineGroupName = 'Multiple Airlines'
		 END
         
        RETURN @AirlineGroupName

END
GO
