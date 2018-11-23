
CREATE PROCEDURE [Staging].[new_validateMobile]
    @DataImportDetailID INT
AS --Compare against [dayphoneno] - validate to [ParsedAddressMobile1]

--Clean DataSet
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile1] = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(STUFF([dayphoneno],
                                                              PATINDEX('%[^0-9]%',
                                                              [dayphoneno]), 1,
                                                              ''),
                                                              [dayphoneno]),
                                                              ' ', ''), '-',
                                                             ''), '+', ''),
                                             ')', '')
    WHERE   [DataImportDetailID] = @DataImportDetailID;
--check mobile length
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd1] = 0
           ,[ParsedMobileScore1] = 0
           ,[ParsedAddressMobile1] = NULL
    WHERE   (LEN([ParsedAddressMobile1]) < 10
             OR LEN([ParsedAddressMobile1]) > 15
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--Only interested in righthand 10 nums
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile1] = RIGHT([ParsedAddressMobile1], 10)
    WHERE   [ParsedAddressMobile1] IS NOT NULL
            AND [DataImportDetailID] = @DataImportDetailID;
 			
--check for nulls
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd1] = 0
           ,[ParsedMobileScore1] = 0
           ,[ParsedAddressMobile1] = ''
    WHERE   ([dayphoneno] IS NULL
             OR [dayphoneno] = ''
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--update US numbers
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd1] = 1
           ,[ParsedMobileScore1] = 80
           ,[ParsedAddressMobile1] = NULL
    WHERE   [dayphoneno] LIKE '+1%'
            AND LEN([ParsedAddressMobile1]) = 10
            AND [DataImportDetailID] = @DataImportDetailID;
			
--check UK numbers
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd1] = 0
           ,[ParsedMobileScore1] = 0
           ,[ParsedAddressMobile1] = NULL
    WHERE   ([ParsedAddressMobile1] NOT LIKE '7%'
             OR LEN([ParsedAddressMobile1]) < 10
            )
            AND [DataImportDetailID] = @DataImportDetailID;
		
--add 0 and update moble parsed indicator and score
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile1] = CAST(0 AS VARCHAR(1)) + [ParsedAddressMobile1]
	        ,ParsedMobileInd1 = 1
			,ParsedMobileScore1 = CASE WHEN ParsedMobileScore1 > 0 THEN  ParsedMobileScore1 ELSE 100 END 
    WHERE   [ParsedAddressMobile1] IS NOT NULL
            AND [DataImportDetailID] = @DataImportDetailID; 

	UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET      ParsedMobileInd1 = 0
			,ParsedMobileScore1 = 0
    WHERE   [ParsedAddressMobile1] IS  NULL
            AND [DataImportDetailID] = @DataImportDetailID;

--Compare against [eveningphoneno] - validate to [parsedAddressMobile2]

--Clean DataSet
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile2] = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(STUFF([eveningphoneno],
                                                              PATINDEX('%[^0-9]%',
                                                              [eveningphoneno]),
                                                              1, ''),
                                                              [eveningphoneno]),
                                                              ' ', ''), '-',
                                                             ''), '+', ''),
                                             ')', '')
    WHERE   [DataImportDetailID] = @DataImportDetailID;
	
--check mobile length
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd2] = 0
           ,[ParsedMobileScore2] = 0
           ,[ParsedAddressMobile2] = NULL
    WHERE   (LEN([ParsedAddressMobile2]) < 10
             OR LEN([ParsedAddressMobile2]) > 15
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--Only interested in righthand 10 nums
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile2] = RIGHT([ParsedAddressMobile2], 10)
    WHERE   [ParsedAddressMobile2] IS NOT NULL
            AND [DataImportDetailID] = @DataImportDetailID;
 			
--check for nulls
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd2] = 0
           ,[ParsedMobileScore2] = 0
           ,[ParsedAddressMobile2] = ''
    WHERE   ([eveningphoneno] IS NULL
             OR [eveningphoneno] = ''
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--update US numbers
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd2] = 1
           ,[ParsedMobileScore2] = 80
           ,[ParsedAddressMobile2] = NULL
    WHERE   [eveningphoneno] LIKE '+1%'
            AND LEN([ParsedAddressMobile2]) = 10
            AND [DataImportDetailID] = @DataImportDetailID;
			
--check UK numbers
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd2] = 0
           ,[ParsedMobileScore2] = 0
           ,[ParsedAddressMobile2] = NULL
    WHERE   ([ParsedAddressMobile2] NOT LIKE '7%'
             OR LEN([ParsedAddressMobile2]) < 10
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--add 0 and update moble parsed indicator and score
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile2] = CAST(0 AS VARCHAR(1)) + [ParsedAddressMobile2]
			,ParsedMobileInd2 = 1
			,ParsedMobileScore2 = CASE WHEN ParsedMobileScore2 > 0 THEN  ParsedMobileScore2 ELSE 100 END 
    WHERE   [ParsedAddressMobile2] IS NOT NULL
            AND [DataImportDetailID] = @DataImportDetailID;

	UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET      ParsedMobileInd2 = 0
			,ParsedMobileScore2 = 0
    WHERE   [ParsedAddressMobile2] IS  NULL
            AND [DataImportDetailID] = @DataImportDetailID;

--Compare against [MobileTelephoneNo] - validate to [ParsedAddressMobile]

--Clean DataSet
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile] = REPLACE(REPLACE(REPLACE(REPLACE(ISNULL(STUFF([MobileTelephoneNo],
                                                              PATINDEX('%[^0-9]%',
                                                              [MobileTelephoneNo]),
                                                              1, ''),
                                                              [MobileTelephoneNo]),
                                                              ' ', ''), '-',
                                                            ''), '+', ''), ')',
                                            '')
    WHERE   [DataImportDetailID] = @DataImportDetailID;
	
--check mobile length
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd] = 0
           ,[ParsedMobileScore] = 0
           ,[ParsedAddressMobile] = NULL
    WHERE   (LEN([ParsedAddressMobile]) < 10
             OR LEN([ParsedAddressMobile]) > 15
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--Only interested in righthand 10 nums
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile] = RIGHT([ParsedAddressMobile], 10)
    WHERE   [ParsedAddressMobile] IS NOT NULL
            AND [DataImportDetailID] = @DataImportDetailID;
 			
--check for nulls
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd] = 0
           ,[ParsedMobileScore] = 0
           ,[ParsedAddressMobile] = ''
    WHERE   ([MobileTelephoneNo] IS NULL
             OR [MobileTelephoneNo] = ''
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--update US numbers
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd] = 1
           ,[ParsedMobileScore] = 80
           ,[ParsedAddressMobile] = NULL
    WHERE   [MobileTelephoneNo] LIKE '+1%'
            AND LEN([ParsedAddressMobile]) = 10
            AND [DataImportDetailID] = @DataImportDetailID;
			
--check UK numbers
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedMobileInd] = 0
           ,[ParsedMobileScore] = 0
           ,[ParsedAddressMobile] = NULL
    WHERE   ([ParsedAddressMobile] NOT LIKE '7%'
             OR LEN([ParsedAddressMobile]) < 10
            )
            AND [DataImportDetailID] = @DataImportDetailID;

--add 0 and update moble parsed indicator and score
    UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET     [ParsedAddressMobile] = CAST(0 AS VARCHAR(1)) + [ParsedAddressMobile]
	        ,ParsedMobileInd = 1
			,ParsedMobileScore = CASE WHEN ParsedMobileScore > 0 THEN  ParsedMobileScore ELSE 100 END 
    WHERE   [ParsedAddressMobile] IS NOT NULL
            AND [DataImportDetailID] = @DataImportDetailID; 

	UPDATE  [PreProcessing].[TOCPLUS_Customer]
    SET      ParsedMobileInd = 0
			,ParsedMobileScore = 0
    WHERE   [ParsedAddressMobile] IS  NULL
            AND [DataImportDetailID] = @DataImportDetailID;

	

GO


