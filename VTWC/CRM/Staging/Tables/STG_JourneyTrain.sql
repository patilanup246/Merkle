CREATE TABLE [Staging].[STG_JourneyTrain] (
    [JourneyTrainID]        INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                  NVARCHAR (256)  NULL,
    [Description]           NVARCHAR (4000) NULL,
    [CreatedDate]           DATETIME        NOT NULL,
    [CreatedBy]             INT             NOT NULL,
    [LastModifiedDate]      DATETIME        NOT NULL,
    [LastModifiedBy]        INT             NOT NULL,
    [ArchivedInd]           BIT             DEFAULT ((0)) NOT NULL,
    [SourceCreatedDate]     DATETIME        NOT NULL,
    [SourceModifiedDate]    DATETIME        NOT NULL,
    [InformationSourceID]   INT             NOT NULL,
    [DepartureDate]         DATE            NOT NULL,
    [TrainUID]              NVARCHAR (256)  NOT NULL,
    [TrainCategory]         NVARCHAR (256)  NULL,
    [LocationIDOrigin]      INT             NOT NULL,
    [LocationIDDestination] INT             NOT NULL,
    CONSTRAINT [cndx_PrimaryKey_JourneyTrain] PRIMARY KEY CLUSTERED ([JourneyTrainID] ASC),
    CONSTRAINT [FK_JourneyTrain_InformationSourceID] FOREIGN KEY ([InformationSourceID]) REFERENCES [Reference].[InformationSource] ([InformationSourceID]),
    CONSTRAINT [FK_LocationIDDestination_InformationSourceID] FOREIGN KEY ([LocationIDDestination]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_LocationIDOrigin_InformationSourceID] FOREIGN KEY ([LocationIDOrigin]) REFERENCES [Reference].[Location] ([LocationID])
);

