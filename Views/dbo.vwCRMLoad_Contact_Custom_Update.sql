SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwCRMLoad_Contact_Custom_Update]
AS
SELECT  
	 z.[crm_id] Id																											 
	,b.SSID_Winner SSB_CRMSYSTEM_SSID_Winner__c																				 --,c.SSB_CRMSYSTEM_SSID_Winner__c
	,b.DimCustIDs SSB_CRMSYSTEM_DimCustomerID__c																			 --,c.SSB_CRMSYSTEM_DimCustomerID__c
	,LEFT(b.TM_IDs,255) SSB_CRMSYSTEM_SSID_TM__c																			 --,c.SSB_CRMSYSTEM_SSID_TM__c
	,b.AccountID SSB_CRMSYSTEM_TM_Account_ID__c																				 --,c.SSB_CRMSYSTEM_TM_Account_ID__c
	,b.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c																			 --,c.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c
	,b.SSB_CRMSYSTEM_Last_Donation_Date__c																					 --,c.SSB_CRMSYSTEM_Last_Donation_Date__c
	,ISNULL(b.SSB_CRMSYSTEM_Donor_Warning__c,0)  SSB_CRMSYSTEM_Donor_Warning__c												 --,c.SSB_CRMSYSTEM_Donor_Warning__c
	,b.SSB_CRMSYSTEM_Total_Priority_Points__c																				 --,c.SSB_CRMSYSTEM_Total_Priority_Points__c
	,ISNULL(b.SSB_CRMSYSTEM_Football_STH__c,0) SSB_CRMSYSTEM_Football_STH__c												 --,c.SSB_CRMSYSTEM_Football_STH__c
	,ISNULL(b.SSB_CRMSYSTEM_Football_Rookie__c,0)  SSB_CRMSYSTEM_Football_Rookie__c											 --,c.SSB_CRMSYSTEM_Football_Rookie__c
	,ISNULL(b.SSB_CRMSYSTEM_Football_Partial__c,0)  SSB_CRMSYSTEM_Football_Partial__c										 --,c.SSB_CRMSYSTEM_Football_Partial__c
	,ISNULL(b.SSB_CRMSYSTEM_Mens_Basketball_STH__c,0)  SSB_CRMSYSTEM_Mens_Basketball_STH__c									 --,c.SSB_CRMSYSTEM_Mens_Basketball_STH__c
	,ISNULL(b.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c,0) SSB_CRMSYSTEM_Mens_Basketball_Rookie__c							 --,c.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c
	,ISNULL(b.SSB_CRMSYSTEM_Mens_Basketball_Partial__c,0) SSB_CRMSYSTEM_Mens_Basketball_Partial__c							 --,c.SSB_CRMSYSTEM_Mens_Basketball_Partial__c
	,b.SSB_CRMSYSTEM_CY_Donation_Level__c																					 --,c.SSB_CRMSYSTEM_CY_Donation_Level__c
	,b.SSB_CRMSYSTEM_CY_Donation_Amount__c																					 --,c.SSB_CRMSYSTEM_CY_Donation_Amount__c
	,b.SSB_CRMSYSTEM_CY_Donation_Upsell__c																					 --,c.SSB_CRMSYSTEM_CY_Donation_Upsell__c
	,a.Email																												 --,c.Email
	,z.IsBusinessAccount SSB_CRMSYSTEM_CorporateBuyer_Flag__c																 --,c.SSB_CRMSYSTEM_CorporateBuyer_Flag__c
    ,b.SSB_CRMSYSTEM_Company_Name__c																						 --,c.SSB_CRMSYSTEM_Company_Name__c
	, c.AccountId																											 --,c.AccountId
	,ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c,0) SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c							 --,c.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c
	,ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c,0) SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c						 --,c.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c
	,ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c,0) SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c					 --,c.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c
	,ISNULL(b.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c,0) SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c					 --,c.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c
	,b.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c									 --,c.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c
	,b.HomePhone																											 --,c.HomePhone
	,b.MobilePhone																											 --,c.MobilePhone
	,b.SSB_CRMSYSTEM_Consecutive_Years__c																					 --,c.SSB_CRMSYSTEM_Consecutive_Years__c
	,b.SSB_CRMSYSTEM_Millenium_ID__c																						 --,c.SSB_CRMSYSTEM_Millenium_ID__c
	,b.household_income__c																									 --,c.household_income__c
	,b.SSB_CRMSYSTEM_Personicx_Cluster__c																					 --,c.SSB_CRMSYSTEM_Personicx_Cluster__c
	,b.SSB_CRMSYSTEM_Net_Worth__c																							 --,c.SSB_CRMSYSTEM_Net_Worth__c
	,b.SSB_CRMSYSTEM_Football_Priority__c																					 --,c.SSB_CRMSYSTEM_Football_Priority__c
	,b.SSB_CRMSYSTEM_Basketball_Priority__c																					 --,c.SSB_CRMSYSTEM_Basketball_Priority__c
	,b.SSB_CRMSYSTEM_PresenceofChildren__c																					 --,c.SSB_CRMSYSTEM_PresenceofChildren__c
	,b.SSB_CRMSYSTEM_Football_Priority_Date__c																				 --,c.SSB_CRMSYSTEM_Football_Priority_Date__c
	,b.SSB_CRMSYSTEM_Group_Buyer__c																							 --,c.SSB_CRMSYSTEM_Group_Buyer__c
	,b.SSB_CRMSYSTEM_First_Donation_Date__c																					 --,c.SSB_CRMSYSTEM_First_Donation_Date__c
	,b.SSB_CRMSYSTEM_Student_Class_Standing__c																				 --,c.SSB_CRMSYSTEM_Student_Class_Standing__c
	,b.SSB_CRMSYSTEM_Student_Completed_Hours__c  																			 --,c.SSB_CRMSYSTEM_Student_Completed_Hours__c
	,b.SSB_CRMSYSTEM_Student_Semester_Hours__c																				 --,c.SSB_CRMSYSTEM_Student_Semester_Hours__c
	,b.SSB_CRMSYSTEM_Student_College__c																						 --,c.SSB_CRMSYSTEM_Student_College__c
	,b.SSB_CRMSYSTEM_Student_Housing__c																						 --,c.SSB_CRMSYSTEM_Student_Housing__c
	,b.SSB_CRMSYSTEM_Account_Type__c 																						 --,c.SSB_CRMSYSTEM_Account_Type__c 
 

	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(  b.SSID_Winner AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_SSID_Winner__c AS VARCHAR(MAX)))),'')) 																			   then 1 else 0 end as SSB_CRMSYSTEM_SSID_Winner__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.DimCustIDs AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(  c.SSB_CRMSYSTEM_DimCustomerID__c AS VARCHAR(MAX)))),'')) 																		   then 1 else 0 end as SSB_CRMSYSTEM_DimCustomerID__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( LEFT(b.TM_IDs,255) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_SSID_TM__c AS VARCHAR(MAX)))),''))																			   then 1 else 0 end as SSB_CRMSYSTEM_SSID_TM__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.AccountID AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_TM_Account_ID__c AS VARCHAR(MAX)))),''))																			   then 1 else 0 end as SSB_CRMSYSTEM_TM_Account_ID__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c AS VARCHAR(MAX)))),''))								   then 1 else 0 end as SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Last_Donation_Date__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Last_Donation_Date__c AS VARCHAR(MAX)))),''))											   then 1 else 0 end as SSB_CRMSYSTEM_Last_Donation_Date__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Donor_Warning__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Donor_Warning__c AS VARCHAR(MAX)))),''))														   then 1 else 0 end as SSB_CRMSYSTEM_Donor_Warning__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Total_Priority_Points__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Total_Priority_Points__c AS decimal(18,2)))),''))									   then 1 else 0 end as SSB_CRMSYSTEM_Total_Priority_Points__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_STH__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_STH__c AS VARCHAR(MAX)))),''))															   then 1 else 0 end as SSB_CRMSYSTEM_Football_STH__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Rookie__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Rookie__c AS VARCHAR(MAX)))),''))													   then 1 else 0 end as SSB_CRMSYSTEM_Football_Rookie__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Partial__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Partial__c AS VARCHAR(MAX)))),''))													   then 1 else 0 end as SSB_CRMSYSTEM_Football_Partial__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Mens_Basketball_STH__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Mens_Basketball_STH__c AS VARCHAR(MAX)))),''))											   then 1 else 0 end as SSB_CRMSYSTEM_Mens_Basketball_STH__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c AS VARCHAR(MAX)))),''))										   then 1 else 0 end as SSB_CRMSYSTEM_Mens_Basketball_Rookie__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Mens_Basketball_Partial__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Mens_Basketball_Partial__c AS VARCHAR(MAX)))),''))									   then 1 else 0 end as SSB_CRMSYSTEM_Mens_Basketball_Partial__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CY_Donation_Level__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CY_Donation_Level__c AS VARCHAR(MAX)))),''))												   then 1 else 0 end as SSB_CRMSYSTEM_CY_Donation_Level__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CY_Donation_Amount__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CY_Donation_Amount__c AS DECIMAL(18,2)))),''))											   then 1 else 0 end as SSB_CRMSYSTEM_CY_Donation_Amount__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( CAST(b.SSB_CRMSYSTEM_CY_Donation_Upsell__c AS INT) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CY_Donation_Upsell__c AS VARCHAR(MAX)))),''))											   then 1 else 0 end as SSB_CRMSYSTEM_CY_Donation_Upsell__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( a.Email AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.Email AS VARCHAR(MAX)))),''))																										   then 1 else 0 end as Email
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Company_Name__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Company_Name__c AS VARCHAR(MAX)))),''))														   then 1 else 0 end as SSB_CRMSYSTEM_Company_Name__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c,0) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c AS VARCHAR(MAX)))),''))						   then 1 else 0 end as SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c 
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c,0) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c AS VARCHAR(MAX)))),''))					   then 1 else 0 end as SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c,0) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c AS VARCHAR(MAX)))),''))					   then 1 else 0 end as SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c AS DECIMAL(18,2)))),''))									   then 1 else 0 end as SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.HomePhone AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.HomePhone AS VARCHAR(MAX)))),''))																								   then 1 else 0 end as HomePhone
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.MobilePhone AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.MobilePhone AS VARCHAR(MAX)))),''))																							   then 1 else 0 end as MobilePhone
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Consecutive_Years__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Consecutive_Years__c AS DECIMAL(18,2)))),''))												   then 1 else 0 end as SSB_CRMSYSTEM_Consecutive_Years__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Millenium_ID__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Millenium_ID__c AS VARCHAR(MAX)))),''))														   then 1 else 0 end as SSB_CRMSYSTEM_Millenium_ID__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c AS VARCHAR(MAX)))),0))							   then 1 else 0 end as SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.household_income__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.household_income__c AS VARCHAR(MAX)))),''))																			   then 1 else 0 end as  household_income__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Personicx_Cluster__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Personicx_Cluster__c AS VARCHAR(MAX)))),''))												   then 1 else 0 end as  SSB_CRMSYSTEM_Personicx_Cluster__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Net_Worth__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Net_Worth__c AS VARCHAR(MAX)))),''))																   then 1 else 0 end as  SSB_CRMSYSTEM_Net_Worth__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Priority__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Priority__c AS VARCHAR(MAX)))),''))												   then 1 else 0 end as  SSB_CRMSYSTEM_Football_Priority__c
	--,case when  HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Basketball_Priority__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Basketball_Priority__c AS VARCHAR(MAX)))),''))											   then 1 else 0 end as  SSB_CRMSYSTEM_Basketball_Priority__c
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_PresenceofChildren__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_PresenceofChildren__c AS NVARCHAR(MAX)))),''))												   then 1 else 0 end as  SSB_CRMSYSTEM_PresenceofChildren__c			
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Class_Standing__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Class_Standing__c AS NVARCHAR(MAX)))),''))										   then 1 else 0 end as  SSB_CRMSYSTEM_Football_Priority_Date__c		
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Completed_Hours__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Completed_Hours__c AS NVARCHAR(MAX)))),''))									   then 1 else 0 end as  SSB_CRMSYSTEM_Group_Buyer__c					
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Semester_Hours__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Semester_Hours__c AS NVARCHAR(MAX)))),''))										   then 1 else 0 end as  SSB_CRMSYSTEM_First_Donation_Date__c			
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_College__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_College__c AS NVARCHAR(MAX)))),''))													   then 1 else 0 end as  SSB_CRMSYSTEM_Student_Class_Standing__c		
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Housing__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Housing__c AS NVARCHAR(MAX)))),''))													   then 1 else 0 end as  SSB_CRMSYSTEM_Student_Completed_Hours__c  	
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Account_Type__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Account_Type__c AS NVARCHAR(MAX)))),''))															   then 1 else 0 end as  SSB_CRMSYSTEM_Student_Semester_Hours__c		
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Priority_Date__c AS DATE))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Priority_Date__c AS DATE))),''))														   then 1 else 0 end as  SSB_CRMSYSTEM_Student_College__c				
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Group_Buyer__c AS DATE))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Group_Buyer__c AS DATE))),''))																				   then 1 else 0 end as  SSB_CRMSYSTEM_Student_Housing__c				
	--,case when HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_First_Donation_Date__c AS DATE))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_First_Donation_Date__c AS DATE))),''))																   then 1 else 0 end as  SSB_CRMSYSTEM_Account_Type__c 				
																																																																												
																																																																												
FROM dbo.[vwCRMLoad_Contact_Std_Prep] a
INNER JOIN dbo.[Contact_Custom] b ON [a].[SSB_CRMSYSTEM_CONTACT_ID__c] = b.[SSB_CRMSYSTEM_CONTACT_ID]
INNER JOIN dbo.Contact z ON a.[SSB_CRMSYSTEM_CONTACT_ID__c] = z.[SSB_CRMSYSTEM_CONTACT_ID]
LEFT JOIN  prodcopy.vw_contact c ON z.[crm_id] = c.ID
WHERE z.[SSB_CRMSYSTEM_CONTACT_ID] <> z.[crm_id]
AND  (1=2
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(  b.SSID_Winner AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_SSID_Winner__c AS VARCHAR(MAX)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.DimCustIDs AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST(  c.SSB_CRMSYSTEM_DimCustomerID__c AS VARCHAR(MAX)))),'')) 
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( LEFT(b.TM_IDs,255) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_SSID_TM__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.AccountID AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_TM_Account_ID__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Last_Ticket_Purchase_Date__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Last_Donation_Date__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Last_Donation_Date__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Donor_Warning__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Donor_Warning__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Total_Priority_Points__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Total_Priority_Points__c AS DECIMAL(18,2)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_STH__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_STH__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Rookie__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Rookie__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Partial__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Partial__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Mens_Basketball_STH__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Mens_Basketball_STH__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Mens_Basketball_Rookie__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Mens_Basketball_Partial__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Mens_Basketball_Partial__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CY_Donation_Level__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CY_Donation_Level__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CY_Donation_Amount__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CY_Donation_Amount__c AS DECIMAL(18,2)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( CAST(b.SSB_CRMSYSTEM_CY_Donation_Upsell__c AS INT) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CY_Donation_Upsell__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( a.Email AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.Email AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Company_Name__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Company_Name__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c,0) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Group_Buyer__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c,0) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Premium_Buyer__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( ISNULL(b.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c,0) AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Suite_Prospect__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC11_16_Total_Spend__c AS DECIMAL(18,2)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.HomePhone AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.HomePhone AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.MobilePhone AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.MobilePhone AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Consecutive_Years__c AS DECIMAL(18,2)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Consecutive_Years__c AS DECIMAL(18,2)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Millenium_ID__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Millenium_ID__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c AS VARCHAR(MAX)))),0) )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_CLA_CC1116_ConcertProspect__c AS VARCHAR(MAX)))),0))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.household_income__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.household_income__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Personicx_Cluster__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Personicx_Cluster__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Net_Worth__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Net_Worth__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Priority__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Priority__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Basketball_Priority__c AS VARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Basketball_Priority__c AS VARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_PresenceofChildren__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_PresenceofChildren__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Class_Standing__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Class_Standing__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Completed_Hours__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Completed_Hours__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Semester_Hours__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Semester_Hours__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_College__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_College__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Student_Housing__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Student_Housing__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Account_Type__c AS NVARCHAR(MAX)))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Account_Type__c AS NVARCHAR(MAX)))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Football_Priority_Date__c AS DATE))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Football_Priority_Date__c AS DATE))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_Group_Buyer__c AS DATE))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_Group_Buyer__c AS DATE))),''))
	OR HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( b.SSB_CRMSYSTEM_First_Donation_Date__c AS DATE))),'') )  <> HASHBYTES('SHA2_256',ISNULL(LTRIM(RTRIM(CAST( c.SSB_CRMSYSTEM_First_Donation_Date__c AS DATE))),''))


	)




	




GO
