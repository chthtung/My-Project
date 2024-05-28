SELECT [ProductKey]
      ,[ProductAlternateKey] AS ProductCode
--      ,p.[ProductSubcategoryKey]
--      ,[WeightUnitMeasureCode]
--      ,[SizeUnitMeasureCode]
      ,[EnglishProductName] AS ProductName
	  , ps.EnglishProductSubcategoryName AS SubCategory
	  , pc.EnglishProductCategoryName AS ProductCategory
--      ,[SpanishProductName]
--      ,[FrenchProductName]
--      ,[StandardCost]
--      ,[FinishedGoodsFlag]
      ,[Color] AS ProductColor
--      ,[SafetyStockLevel]
--      ,[ReorderPoint]
--      ,[ListPrice]
      ,[Size] AS ProductSize
--      ,[SizeRange]
--      ,[Weight]
--      ,[DaysToManufacture]
      ,[ProductLine]
--      ,[DealerPrice]
--      ,[Class]
--      ,[Style]
      ,[ModelName] AS ProductModelName
--      ,[LargePhoto]
      ,[EnglishDescription] AS ProductDescription
--      ,[FrenchDescription]
--      ,[ChineseDescription]
--      ,[ArabicDescription]
--      ,[HebrewDescription]
--      ,[ThaiDescription]
--      ,[GermanDescription]
--      ,[JapaneseDescription]
--      ,[TurkishDescription]
--      ,[StartDate]
--      ,[EndDate]
      ,ISNULL(Status, 'OutDated') AS ProductStatus
  FROM [AdventureWorksDW2019].[dbo].[DimProduct] p
  LEFT JOIN DimProductSubcategory ps ON ps.ProductSubcategoryKey = p.ProductSubcategoryKey
  LEFT JOIN DimProductCategory pc ON pc.ProductCategoryKey = ps.ProductCategoryKey

  ORDER BY ProductKey ASC
