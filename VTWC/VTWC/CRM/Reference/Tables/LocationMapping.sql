CREATE TABLE [Reference].[LocationMapping] (
    [MapID]            INT      IDENTITY (1, 1) NOT NULL,
    [TypeID]           INT      NOT NULL,
    [LocationGroupID]  INT      NOT NULL,
    [LocationID]       INT      NOT NULL,
    [CreatedDate]      DATETIME NOT NULL,
    [CreatedBy]        INT      NOT NULL,
    [LastModifiedDate] DATETIME NOT NULL,
    [LastModifiedBy]   INT      NOT NULL,
    [ArchivedInd]      BIT      NOT NULL,
    CONSTRAINT [PK_Location_Region_Mapping] PRIMARY KEY CLUSTERED ([MapID] ASC),
    CONSTRAINT [FK_Location_Region_Mapping_Location] FOREIGN KEY ([LocationID]) REFERENCES [Reference].[Location] ([LocationID]),
    CONSTRAINT [FK_Location_Region_Mapping_LocationGroup] FOREIGN KEY ([LocationGroupID]) REFERENCES [Reference].[LocationGroup] ([LocationGroupID]),
    CONSTRAINT [FK_Location_Region_Mapping_Type] FOREIGN KEY ([TypeID]) REFERENCES [Reference].[LocationMappingType] ([TypeID]),
    CONSTRAINT [IX_LocationMapping] UNIQUE NONCLUSTERED ([TypeID] ASC, [LocationID] ASC)
);



