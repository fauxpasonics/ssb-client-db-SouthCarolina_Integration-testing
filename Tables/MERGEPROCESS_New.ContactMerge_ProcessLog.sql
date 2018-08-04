CREATE TABLE [MERGEPROCESS_New].[ContactMerge_ProcessLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ProcessDate] [datetime] NOT NULL CONSTRAINT [DF__ContactMe__Proce__5224328E] DEFAULT (getdate()),
[contactid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[losing_contactid] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorColumn] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMessage] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
