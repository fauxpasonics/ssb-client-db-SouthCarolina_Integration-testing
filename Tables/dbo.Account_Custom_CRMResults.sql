CREATE TABLE [dbo].[Account_Custom_CRMResults]
(
[SSB_CRMSYSTEM_SSID_Winner__c] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c] [date] NULL,
[SSB_CRMSYSTEM_Last_Donation_Date__c] [date] NULL,
[SSB_CRMSYSTEM_Donor_Warning__c] [bit] NULL,
[SSB_CRMSYSTEM_Total_Priority_Points__c] [numeric] (7, 2) NULL,
[SSB_CRMSYSTEM_Football_STH__c] [bit] NULL,
[SSB_CRMSYSTEM_CY_Donation_Level__c] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSB_CRMSYSTEM_CY_Donation_Amount__c] [numeric] (18, 2) NULL,
[SSB_CRMSYSTEM_DimCustomerID__c] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSB_CRMSYSTEM_SSID_TM__c] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSB_CRMSYSTEM_TM_Account_ID__c] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SSB_CRMSYSTEM_Football_Rookie__c] [bit] NULL,
[SSB_CRMSYSTEM_Football_Partial__c] [bit] NULL,
[SSB_CRMSYSTEM_Mens_Basketball_STH__c] [bit] NULL,
[SSB_CRMSYSTEM_Mens_Basketball_Rookie__c] [bit] NULL,
[SSB_CRMSYSTEM_Mens_Basketball_Partial__c] [bit] NULL,
[SSB_CRMSYSTEM_CY_Donation_Upsell__c] [numeric] (10, 2) NULL,
[ErrorCode] [int] NULL,
[ErrorColumn] [int] NULL,
[Update SF Dest.Id] [nvarchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Update.Id] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorDescription] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ResultsDateTime] [datetime] NULL CONSTRAINT [DF__Account_C__Resul__3587F3E0] DEFAULT (getdate())
)
GO
