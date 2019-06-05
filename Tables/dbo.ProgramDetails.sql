CREATE TABLE [dbo].[ProgramDetails]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[AirLineCode] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProgramCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HaulType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BrandCode] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActive] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ProgramDetails] ADD CONSTRAINT [PK_ProgramDetails] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
