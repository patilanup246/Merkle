CREATE TABLE [Staging].[STG_Individual](
	[IndividualID] [int] IDENTITY(1,1) NOT NULL,
	[Description] [nvarchar](4000) NULL,
	[CreatedDate] [datetime] NOT NULL,
	[CreatedBy] [int] NOT NULL,
	[LastModifiedDate] [datetime] NOT NULL,
	[LastModifiedBy] [int] NOT NULL,
	[ArchivedInd] [bit] NOT NULL,
	[ExtReference] [nvarchar](256) NULL,
	[SourceCreatedDate] [datetime] NULL,
	[SourceModifiedDate] [datetime] NULL,
	[IsStaffInd] [bit] NOT NULL,
	[IsBlackListInd] [bit] NOT NULL,
	[IsTMCInd] [bit] NOT NULL,
	[IsCorporateInd] [bit] NOT NULL,
	[InformationSourceID] [int] NOT NULL,
	[Salutation] [nvarchar](64) NULL,
	[FirstName] [nvarchar](64) NULL,
	[MiddleName] [nvarchar](64) NULL,
	[LastName] [nvarchar](64) NULL,
	[DateFirstPurchase] [datetime] NULL,
	[DateLastPurchase] [datetime] NULL,
	[YearOfBirth] [int] NULL,
 CONSTRAINT [cndx_PrimaryKey_Stg_Individual] PRIMARY KEY CLUSTERED 
(
	[IndividualID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [Staging].[STG_Individual] ADD  DEFAULT ((0)) FOR [ArchivedInd]
GO
