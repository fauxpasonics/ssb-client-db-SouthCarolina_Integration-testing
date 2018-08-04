SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [MERGEPROCESS_New].[vw_Cust_Contact_ColumnLogic]
AS
SELECT  ID AS ID ,
		Losing_ID AS Losing_ID ,
        ISNULL(CAST(SUBSTRING(aa.HasOptedOutOfEmail, 2, 1) AS BIT),0) HasOptedOutofEmail ,
		ISNULL(CAST(SUBSTRING(aa.hed__Do_Not_Contact__c, 2, 1) AS BIT),0) Hed__Do_Not_Contact__c ,
		ISNULL(CAST(SUBSTRING(aa.HasOptedOutOfFax, 2, 1) AS BIT),0) HasOptedOutofFax,
		ISNULL(CAST(SUBSTRING(aa.DoNotCall, 2, 1) AS BIT),0) DoNotCall
FROM    ( SELECT    Winning_ID AS ID ,
					Losing_ID AS Losing_ID ,					--	DCH 2016-10-04
                    MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND ISNULL(dta.HasOptedOutOfEmail,0) <> 0
                             THEN '2' + CAST(dta.HasOptedOutOfEmail AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND ISNULL(dta.HasOptedOutOfEmail,0) <> 0
                             THEN '1' + CAST(dta.HasOptedOutOfEmail AS VARCHAR(10))
                        END) HasOptedOutOfEmail ,
					MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND ISNULL(dta.[hed__Do_Not_Contact__c],0) <> 0
                             THEN '2' + CAST(dta.[hed__Do_Not_Contact__c] AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND ISNULL(dta.[hed__Do_Not_Contact__c],0) <> 0
                             THEN '1' + CAST(dta.[hed__Do_Not_Contact__c] AS VARCHAR(10))
                        END) [hed__Do_Not_Contact__c] ,
					MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND ISNULL(dta.DoNotCall,0) <> 0
                             THEN '2' + CAST(dta.DoNotCall AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND ISNULL(dta.DoNotCall,0) <> 0
                             THEN '1' + CAST(dta.DoNotCall AS VARCHAR(10))
                        END) donotcall,
					MAX(CASE WHEN dta.xtype = 'Winning'
                                  AND ISNULL(dta.HasOptedOutOfFax,0) <> 0
                             THEN '2' + CAST(dta.HasOptedOutOfFax AS VARCHAR(10))
                             WHEN dta.xtype = 'Losing'
                                  AND ISNULL(dta.HasOptedOutOfFax,0) <> 0
                             THEN '1' + CAST(dta.HasOptedOutOfFax AS VARCHAR(10))
                        END) HasOptedOutofFax

          FROM      ( SELECT    *
                      FROM      ( SELECT    'Winning' xtype ,
                                            a.Winning_ID ,
											a.Losing_ID ,					--	DCH 2016-10-04
                                            b.*
                                  FROM      [MERGEPROCESS_New].[Queue] a
                                            JOIN SouthCarolina_Reporting.Prodcopy.vw_Contact b WITH (NOLOCK) ON a.Winning_ID = b.ID
											WHERE a.ObjectType = 'Contact'
											--where fk_mergeid < 1000
                                  UNION ALL
                                  SELECT    'Losing' xtype ,
                                            a.Winning_ID ,
											a.Losing_ID ,					--	DCH 2016-10-04
                                            b.*
                                  FROM      [MERGEPROCESS_New].[Queue] a
                                            JOIN SouthCarolina_Reporting.Prodcopy.vw_Contact b WITH (NOLOCK) ON a.Losing_ID = b.ID
											WHERE a.ObjectType = 'Contact'
											--where fk_mergeid < 1000
                                ) x
                    ) dta
          GROUP BY  Winning_ID ,
					Losing_ID					--	DCH 2016-10-04				
        ) aa
 --WHERE Losing_ID =  '0034100000PtQYWAA3' AND ID = '0034100000M6gZ3AAJ'

;









GO
