USE [CEM]
GO
/****** Object:  Table [dbo].[awsdms_truncation_safeguard]    Script Date: 24/07/2018 14:20:08 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[awsdms_truncation_safeguard](
	[latchTaskName] [varchar](128) NOT NULL,
	[latchMachineGUID] [varchar](40) NOT NULL,
	[LatchKey] [char](1) NOT NULL,
	[latchLocker] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[latchTaskName] ASC,
	[latchMachineGUID] ASC,
	[LatchKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
