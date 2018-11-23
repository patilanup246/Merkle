



CREATE PROCEDURE [Production].[customer_rfv_history_production]
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

		--delcare variables for CRM auditing
        DECLARE @spname NVARCHAR(256);
        DECLARE @recordcount INTEGER;
        DECLARE @logtimingidnew INTEGER;
        DECLARE @logmessage NVARCHAR(MAX);
        DECLARE @userid INTEGER;

		SELECT  @spname = OBJECT_SCHEMA_NAME(@@PROCID) + '.'
                + OBJECT_NAME(@@PROCID);


		--set userid to be 0 to be consistent with the other calls to the stored proc 
        SET @userid = 0; 

		----Log start time CRM Auditing--

        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingidnew = @logtimingidnew OUTPUT;


	-- FIND THE DIFFERENCES BASED ON THE LATEST RUN
        SELECT  [a].[CustomerID]
               ,[a].[RFV]
        INTO    [#tmp_rfv_hist]
        FROM    [Production].[Customer] [a] WITH (NOLOCK)
        INNER JOIN [Production].[RFV_History] [b] WITH (NOLOCK)
        ON      [a].[CustomerID] = [b].[customerid]
        WHERE   ([a].[RFV] != [b].[rfv_segment]
                 OR [a].[RFV] IS NOT NULL
                 AND [b].[rfv_segment] IS NULL
                 OR [a].[RFV] IS NULL
                 AND [b].[rfv_segment] IS NOT NULL
                )
                AND [b].[effective_to_date] = '3000-12-31';

	-- SET THE OLD RECORDS EFFECTIVE_TO_DATE = Today
        UPDATE  [b]
        SET     [b].[effective_to_date] = CAST(GETDATE() AS DATE)
        FROM    [#tmp_rfv_hist] [a]
        INNER JOIN [CRM].[Production].[RFV_History] [b]
        ON      [a].[CustomerID] = [b].[customerid]
                AND [b].[effective_to_date] = '3000-12-31';

	-- INSERT THE NEW RECORDS WITH THE CORRECT HIGH DATES
        INSERT  INTO [CRM].[Production].[RFV_History]
                ([customerid]
                ,[rfv_segment]
                ,[effective_from_date]
                ,[effective_to_date]
	            )
        SELECT  [CustomerID]
               ,[RFV]
               ,CAST(GETDATE() AS DATE)
               ,'3000-12-31'
        FROM    [#tmp_rfv_hist];

	-- IDENTIFY NEW CUSTOMERS NOT ON RFV HISTORY
        INSERT  INTO [Production].[RFV_History]
                ([customerid]
                ,[rfv_segment]
                ,[effective_from_date]
                ,[effective_to_date]
	            )
        SELECT  [a].[CustomerID]
               ,[a].[RFV]
               ,CAST(GETDATE() AS DATE)
               ,'3000-12-31'
        FROM    [Production].[Customer] [a] WITH (NOLOCK)
        LEFT JOIN [Production].[RFV_History] [b]
        ON      [a].[CustomerID] = [b].[customerid]
        WHERE   [b].[customerid] IS NULL;


        EXEC [Operations].[LogTiming_Record] @userid = @userid,
            @logsource = @spname, @logtimingid = @logtimingidnew,
            @recordcount = @recordcount,
            @logtimingidnew = @logtimingidnew OUTPUT;


    END;