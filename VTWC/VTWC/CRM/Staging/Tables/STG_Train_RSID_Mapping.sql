CREATE TABLE [Staging].[STG_Train_RSID_Mapping] (
    [TravelDate]  DATE           NULL,
    [RSID]        NVARCHAR (256) NULL,
    [trainid]     VARCHAR (512)  NULL,
    [StartTime]   VARCHAR (5)    NULL,
    [ArrivalTime] VARCHAR (5)    NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [ix_Train_RSID_Mapping]
    ON [Staging].[STG_Train_RSID_Mapping]([TravelDate] ASC, [RSID] ASC, [trainid] ASC);

