CREATE TABLE [PreProcessing].[TOCPLUS_Refunds] (
    [TOCRefundsID]        INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TcsBookingID]        BIGINT         NULL,
    [ArRefArrivalId]      BIGINT         NULL,
    [RefundType]          NVARCHAR (20)  NULL,
    [Percentage]          INT            NULL,
    [GrossRefund]         NUMERIC (6, 2) NULL,
    [AdminFee]            INT            NULL,
    [RefundAmount]        NUMERIC (6, 2) NULL,
    [DatamartCreateDate]  DATETIME       NULL,
    [DatamartUpdateDate]  DATETIME       NULL,
    [RequestedDate]       DATETIME       NULL,
    [RefundedIssuedDate]  DATETIME       NULL,
    [RefundReason]        NVARCHAR (20)  NULL,
    [RefundReasonDesc]    NVARCHAR (50)  NULL,
    [CreatedDateETL]      DATETIME       NULL,
    [LastModifiedDateETL] DATETIME       NULL,
    [ProcessedInd]        BIT            NULL,
    [DataImportDetailID]  INT            NULL,
    CONSTRAINT [cndx_PrimaryKey_TOCPLUS_Refunds] PRIMARY KEY CLUSTERED ([TOCRefundsID] ASC)
);



