SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[usp_GetTripForExpenseCompany] (
@beginProcessDays int = -15
)

AS
begin
	DECLARE 
		@lastProcessingDateTime datetime

	CREATE TABLE #ExpenseProcessTemp(
		tripKey int,
		userKey int,
		recordLocator nvarchar(255),
		tripStatusKey int,
		tripRequestkey int,
		siteKey int,
		groupKey int,
		createdDate datetime,
		modifiedDate datetime,
		userEmail nvarchar(100),
		companyKey int,
		expenseSourceId int,
		resourceUrl nvarchar(100),
		api nvarchar(50),
		expenseEmailAddress nvarchar(100),
		preferedCommunication int
	)

	select @lastProcessingDateTime = MAX(last_modified_date) from Trip.DBO.expense_email_processing

	if @lastProcessingDateTime is null
	begin
		select @LastProcessingDateTime = DATEADD(day, @beginProcessDays, GETDATE())

		INSERT INTO #ExpenseProcessTemp
		select top 100 
		t.tripkey, t.userkey, t.recordLocator, t.tripStatusKey, t.triprequestkey, t.siteKey, t.GroupKey, t.CreatedDate, t.ModifiedDateTime
		, up.userEmail
		, c.COMPANYKEY
		, er.expense_resource_id, er.resource_url, er.api, er.primary_email, er.preferred_communication
		FROM Trip.DBO.trip t
		join Vault.DBO.[User]  u
		on t.userKey = u.userKey
		join Vault.DBO.UserProfile up
		on u.userKey = up.userKey
		join Vault.DBO.company c
		on u.companyKey = c.COMPANYKEY
		join Vault.DBO.expense_resource er
		on c.expense_resource_id = er.expense_resource_id
		WHERE tripStatusKey<>17
		AND t.ModifiedDateTime > @lastProcessingDateTime
	end
	else
	begin
		INSERT INTO #ExpenseProcessTemp
		select top 100 
		t.tripkey, t.userkey, t.recordLocator, t.tripStatusKey, t.triprequestkey, t.siteKey, t.GroupKey, t.CreatedDate, t.ModifiedDateTime
		, up.userEmail
		, c.COMPANYKEY
		, er.expense_resource_id, er.resource_url, er.api, er.primary_email, er.preferred_communication
		FROM Trip.DBO.trip t
		join Vault.DBO.[User]  u
		on t.userKey = u.userKey
		join Vault.DBO.UserProfile up
		on u.userKey = up.userKey
		join Vault.DBO.company c
		on u.companyKey = c.COMPANYKEY
		join Vault.DBO.expense_resource er
		on c.expense_resource_id = er.expense_resource_id
		WHERE tripStatusKey<>17
		AND t.ModifiedDateTime > @lastProcessingDateTime
	end
	
	update Trip.DBO.expense_email_processing 
		set trip_status = #ExpenseProcessTemp.tripStatusKey,
			last_modified_date = #ExpenseProcessTemp.modifiedDate,
			is_sent = 0
		from #ExpenseProcessTemp
		where exists (
			select 1 from Trip.DBO.expense_email_processing
			where Trip.DBO.expense_email_processing.tripkey = #ExpenseProcessTemp.tripkey)
			and Trip.DBO.expense_email_processing.last_modified_date < #ExpenseProcessTemp.modifiedDate
			and Trip.DBO.expense_email_processing.tripkey = #ExpenseProcessTemp.tripkey

	INSERT INTO Trip.DBO.expense_email_processing(
		tripkey
		,expense_resource_id
		,trip_status
		,is_sent
		,create_date
		,last_modified_date
		)  
		select 
			tripkey
			,expenseSourceId
			,tripStatusKey
			,0
			,createdDate
			,modifiedDate
		from #ExpenseProcessTemp
		where not exists (
			select 1 from Trip.DBO.expense_email_processing 
			where Trip.DBO.expense_email_processing.tripkey = #ExpenseProcessTemp.tripkey 
				and Trip.DBO.expense_email_processing.last_modified_date = #ExpenseProcessTemp.modifiedDate )

	select * from #ExpenseProcessTemp
end
GO
