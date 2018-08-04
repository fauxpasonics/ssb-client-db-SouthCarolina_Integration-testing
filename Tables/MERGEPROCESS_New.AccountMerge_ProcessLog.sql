CREATE TABLE [MERGEPROCESS_New].[AccountMerge_ProcessLog]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ProcessDate] [datetime] NOT NULL CONSTRAINT [DF__AccountMe__Proce__540C7B00] DEFAULT (getdate()),
[accountid] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[losing_accountid] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ErrorColumn] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMessage] [nvarchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
