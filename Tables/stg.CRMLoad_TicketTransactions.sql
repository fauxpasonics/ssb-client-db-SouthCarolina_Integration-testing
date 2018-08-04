CREATE TABLE [stg].[CRMLoad_TicketTransactions]
(
[Team__c] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TicketingAccountID__c] [int] NULL,
[SeasonName__c] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FactTicketSalesID__c] [bigint] NULL,
[OrderNumber__c] [bigint] NULL,
[OrderLine__c] [int] NULL,
[OrderDate__c] [date] NULL,
[Item__c] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ItemName__c] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EventDate__c] [date] NULL,
[PriceCode__c] [nvarchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsComp__c] [bit] NULL,
[PromoCode__c] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[QtySeat__c] [int] NULL,
[SectionName__c] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowName__c] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Seat__c] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SeatPrice__c] [decimal] (12, 2) NULL,
[Total__c] [decimal] (12, 2) NULL,
[OwedAmount__c] [decimal] (12, 2) NULL,
[PaidAmount__c] [decimal] (12, 2) NULL,
[SalesRep__c] [nvarchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
