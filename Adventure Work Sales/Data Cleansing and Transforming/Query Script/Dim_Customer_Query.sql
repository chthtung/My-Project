-- DimCUSTOMER cleansing

SELECT [CustomerKey]
      ,g.City
--      ,[CustomerAlternateKey]
--      ,[Title]
      ,[FirstName]
--      ,[MiddleName]
      ,[LastName]
	  , FirstName + ' ' + LastName AS FullName
--      ,[NameStyle]
--      ,[BirthDate]
--      ,[MaritalStatus]
--      ,[Suffix]
      , CASE [Gender] WHEN 'M' THEN 'Male' WHEN 'F' THEN 'Female' END AS Gender
--      ,[EmailAddress]
--      ,[YearlyIncome]
--      ,[TotalChildren]
--      ,[NumberChildrenAtHome]
--      ,[EnglishEducation]
--     ,[SpanishEducation]
--      ,[FrenchEducation]
--      ,[EnglishOccupation]
--      ,[SpanishOccupation]
--      ,[FrenchOccupation]
--      ,[HouseOwnerFlag]
--      ,[NumberCarsOwned]
--      ,[AddressLine1]
--     ,[AddressLine2]
--      ,[Phone]
      ,[DateFirstPurchase]
--      ,[CommuteDistance]
  FROM [AdventureWorksDW2019].[dbo].[DimCustomer] c
	LEFT JOIN DimGeography g ON c.GeographyKey = g.GeographyKey
	ORDER BY CustomerKey ASC
