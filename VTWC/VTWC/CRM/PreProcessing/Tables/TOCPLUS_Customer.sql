﻿CREATE TABLE [PreProcessing].[TOCPLUS_Customer] (
    [TOCCustomerID]            INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CMDCustomerID]            BIGINT         NULL,
    [TCScustomerID]            BIGINT         NULL,
    [regretailercode]          NVARCHAR (4)   NULL,
    [firstregdate]             DATETIME       NULL,
    [donotemail]               NCHAR (1)      NULL,
    [donotmail]                NCHAR (1)      NULL,
    [donotsms]                 NCHAR (1)      NULL,
    [thirdpartyoptout]         NCHAR (1)      NULL,
    [emailaddress]             NVARCHAR (100) NULL,
    [dateofbirth]              NVARCHAR (25)  NULL,
    [companyname]              NVARCHAR (100) NULL,
    [addressline1]             NVARCHAR (100) NULL,
    [addressline2]             NVARCHAR (100) NULL,
    [addressline3]             NVARCHAR (100) NULL,
    [addressline4]             NVARCHAR (100) NULL,
    [addressline5]             NVARCHAR (100) NULL,
    [postcode]                 NVARCHAR (10)  NULL,
    [country]                  NVARCHAR (50)  NULL,
    [mosaicgpdesc]             NVARCHAR (50)  NULL,
    [mosaictypedesc]           NVARCHAR (50)  NULL,
    [dayphoneno]               NVARCHAR (50)  NULL,
    [eveningphoneno]           NVARCHAR (50)  NULL,
    [title]                    NVARCHAR (10)  NULL,
    [forename]                 NVARCHAR (50)  NULL,
    [surname]                  NVARCHAR (50)  NULL,
    [homestation]              NVARCHAR (5)   NULL,
    [corpreference]            NVARCHAR (50)  NULL,
    [adminrole]                NVARCHAR (3)   NULL,
    [bookerrole]               NVARCHAR (3)   NULL,
    [accountclosed]            NVARCHAR (3)   NULL,
    [custcmddateupdated]       DATETIME       NULL,
    [regcmddateupdated]        DATETIME       NULL,
    [trusted]                  NVARCHAR (3)   NULL,
    [lifetimevalue]            FLOAT (53)     NULL,
    [firstjourneycompletedate] DATETIME       NULL,
    [affiliatecode]            NVARCHAR (25)  NULL,
    [firsttransdate]           DATETIME       NULL,
    [lasttransdate]            DATETIME       NULL,
    [corporatetype]            NVARCHAR (25)  NULL,
    [managedgroupid]           INT            NULL,
    [vtsegment]                INT            NULL,
    [accountstatus]            NVARCHAR (25)  NULL,
    [retailermarketingoptin]   NVARCHAR (3)   NULL,
    [thirdpartymarketingoptin] NVARCHAR (3)   NULL,
    [CustCMDDateCreated]       DATETIME       NULL,
    [RegChannel]               NVARCHAR (20)  NULL,
    [RegOriginatingSystemType] NVARCHAR (20)  NULL,
    [ExperianDateUpdated]      DATETIME       NULL,
    [Salutation]               NVARCHAR (60)  NULL,
    [MobileTelephoneNo]        NVARCHAR (50)  NULL,
    [FirstCallTranDate]        DATETIME       NULL,
    [FirstIntTranDate]         DATETIME       NULL,
    [FirstMobAppTranDate]      DATETIME       NULL,
    [FirstMobWebTranDate]      DATETIME       NULL,
    [ExperianHouseholdIncome]  NVARCHAR (20)  NULL,
    [ExperianAgeBand]          NVARCHAR (10)  NULL,
    [DftOptInFlag]             NCHAR (1)      NULL,
    [ParsedAddressEmail]       NVARCHAR (100) NULL,
    [ParsedEmailInd]           BIT            NULL,
    [ParsedEmailScore]         INT            NULL,
    [ParsedAddressMobile]      NVARCHAR (25)  NULL,
    [ParsedMobileInd]          BIT            NULL,
    [ParsedMobileScore]        INT            NULL,
    [ProfanityInd]             NCHAR (1)      NULL,
    [CreatedDateETL]           DATETIME       NULL,
    [LastModifiedDateETL]      DATETIME       NULL,
    [ProcessedInd]             BIT            NULL,
    [DataImportDetailID]       INT            NULL,
    [ParsedAddressMobile1]     NVARCHAR (100)  NULL,
    [ParsedMobileInd1]         BIT            DEFAULT ((0)) NULL,
    [ParsedMobileScore1]       INT            DEFAULT ((0)) NULL,
    [ParsedAddressMobile2]     NVARCHAR (100)  NULL,
    [ParsedMobileInd2]         BIT            DEFAULT ((0)) NULL,
    [ParsedMobileScore2]       INT            DEFAULT ((0)) NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Customer] PRIMARY KEY CLUSTERED ([TOCCustomerID] ASC)
);




GO
CREATE NONCLUSTERED INDEX [idx_TOCPLUS_Customer_TCSCustomerID]
    ON [PreProcessing].[TOCPLUS_Customer]([TCScustomerID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [idx_TOCPLUS_Customer_DataImportDetailID]
    ON [PreProcessing].[TOCPLUS_Customer]([DataImportDetailID] ASC) WITH (FILLFACTOR = 80);

