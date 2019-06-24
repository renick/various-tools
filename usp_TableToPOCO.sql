/****** Object:  StoredProcedure [dbo].[usp_TableToPOCO]    
        Script Date: 24/6/2019 9:43:44 πμ 
		
		Just a quick hack to produce correct POCO 
		from (MS)SQL Table 

		USAGE: 
		
		exec usp_TableToPOCO 'YourTableName'

		and set "results to text" in SSMS

		******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[usp_TableToPOCO]

@table_name SYSNAME
AS
SET NOCOUNT ON
DECLARE @temp TABLE(sort INT,code TEXT)

INSERT INTO @temp
SELECT 2, 'using System;' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 3, 'using System.Runtime.Serialization;' + CHAR(13) + CHAR(10)

INSERT INTO @temp
SELECT 5, '[DataContract]' + CHAR(13) + CHAR(10)

INSERT INTO @temp
SELECT 6, 'public class ' + @table_name + CHAR(13) + CHAR(10) + '{'

INSERT INTO @temp
SELECT 8, '#region Public Properties' + CHAR(13) + CHAR(10)
INSERT INTO @temp
SELECT 9,  CHAR(9) + '[DataMember] ' + CHAR(13) + CHAR(10) + CHAR(9) + 'public ' +
CASE
WHEN DATA_TYPE LIKE '%UNIQUEIDENTIFIER%' THEN 'Guid '
WHEN DATA_TYPE LIKE '%CHAR%' THEN 'string '
WHEN DATA_TYPE LIKE '%BIGINT%' THEN 'long? '
WHEN DATA_TYPE LIKE '%INT%' THEN 'int? '
WHEN DATA_TYPE LIKE '%DATETIME%' THEN 'DateTime? '
WHEN DATA_TYPE LIKE '%MONEY%' THEN 'decimal? '
WHEN DATA_TYPE LIKE '%NUMERIC%' THEN 'decimal? '
WHEN DATA_TYPE LIKE '%DECIMAL%' THEN 'decimal? '
WHEN DATA_TYPE LIKE '%BINARY%' THEN 'byte[] '
WHEN DATA_TYPE LIKE '%ROWVERSION%' THEN 'byte[] '
WHEN DATA_TYPE = 'BIT' THEN 'bool? '
WHEN DATA_TYPE LIKE '%TEXT%' THEN 'string '
ELSE 'object '
END + COLUMN_NAME + CHAR(9) + '{ get; set; }' +
CHAR(13) + CHAR(10) 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @table_name
ORDER BY ORDINAL_POSITION

INSERT INTO @temp
SELECT 10, '#endregion' +
CHAR(13) + CHAR(10) + '}' + 
CHAR(13) + CHAR(10) 

SELECT code FROM @temp
ORDER BY sort
GO


