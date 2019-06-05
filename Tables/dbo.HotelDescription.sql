CREATE TABLE [dbo].[HotelDescription]
(
[hotelDescriptionKey] [int] NOT NULL IDENTITY(1, 1),
[hotelResponseKey] [uniqueidentifier] NOT NULL,
[hotelPolicy] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkInInstruction] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tripAdvisorRating] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkInTime] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[checkOutTime] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[taxesAndFeesPolicy] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[HotelDescription] ADD CONSTRAINT [PK_HotelDescription] PRIMARY KEY CLUSTERED  ([hotelDescriptionKey]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ResponseKey] ON [dbo].[HotelDescription] ([hotelResponseKey]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
