CREATE TABLE [dbo].[AirResponseAlternateDate]
(
[airSubRequestKey] [int] NOT NULL,
[airResponseAlternateDateKey] [uniqueidentifier] NOT NULL,
[airResponseAlternateDateOriginDate] [datetime] NOT NULL,
[airResponseAlternateDateReturnDate] [datetime] NULL,
[airResponseAlternateDateAirlineCode] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[airResponseAlternateDatePriceTotal] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AirResponseAlternateDate] ADD CONSTRAINT [PK_NewAirResponseAlternateDate] PRIMARY KEY NONCLUSTERED  ([airResponseAlternateDateKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
