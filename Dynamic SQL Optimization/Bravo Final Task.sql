----------------------------------------------------------------------------------------------
--Task 01: 
SELECT (CASE WHEN GROUPING(ItemCode) = 1 THEN '' ELSE (ItemCode) END) AS ItemCode
	,(CASE WHEN GROUPING(Name) = 1 THEN N'Tổng cộng' ELSE (Name) END) AS Description
	,SUM(CASE WHEN DATEPART(QUARTER,DocDate) = DATEPART(QUARTER,GETDATE()) AND YEAR(DocDate) = YEAR(GETDATE()) THEN Quantity ELSE 0 END) AS Quantity
	,SUM(CASE WHEN DATEPART(QUARTER,DocDate) = DATEPART(QUARTER,GETDATE()) AND YEAR(DocDate) = YEAR(GETDATE()) - 1 THEN Quantity ELSE 0 END) AS Quantity0
FROM Doc d	
	LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	LEFT JOIN Item it ON it.Code = dd.ItemCode
WHERE d.IsActive = 1 
GROUP BY GROUPING SETS ((ItemCode, Name), ())

-----------------------------------------------------------------------------------------------
--Task 02:

--Tạo bảng 1: Nhóm theo đối tượng
DROP TABLE IF EXISTS Group1
SELECT * 
INTO Group1
FROM 
(
	SELECT '' AS DocID
		,'' AS DocDate
		,CustomerCode + ': ' + Cus.Name AS Description
		,'' AS ItemCode
		,SUM(Quantity) AS Quantity
		,CustomerCode AS SP
	FROM Doc d	
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		LEFT JOIN Item it ON it.Code = dd.ItemCode
		LEFT JOIN Customer cus ON cus.Code = d.CustomerCode
	WHERE d.IsActive = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 1
	GROUP BY CustomerCode, Cus.Name
	UNION ALL
	SELECT d.DocId
		,DocDate
		,Description
		,ItemCode
		,Quantity
		,CustomerCode AS SP
	FROM Doc d	
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 1
) Group1

--Tạo bảng 2: Nhóm theo vật tư
DROP TABLE IF EXISTS Group2
SELECT * 
INTO Group2
FROM 
(
	SELECT '' AS DocID
		,'' AS DocDate
		,N'Tổng cộng ' + ItemCode AS Description
		,ItemCode
		,SUM(Quantity) AS Quantity
		,'' AS SP
	FROM Doc d	
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		LEFT JOIN Item it ON it.Code = dd.ItemCode
		LEFT JOIN Customer cus ON cus.Code = d.CustomerCode
	WHERE d.IsActive = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 1
	GROUP BY ItemCode
	UNION ALL
	SELECT d.DocId
		,DocDate
		,Description
		,ItemCode
		,Quantity
		,'' AS SP
	FROM Doc d	
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 1
) Group2


--Tạo bảng 3: Nhóm theo Loại chứng từ
DROP TABLE IF EXISTS Group3
SELECT * 
INTO Group3
FROM 
(
	SELECT '' AS DocID
		,'' AS DocDate
		,(CASE WHEN d.Type = 1 THEN N'NHẬP HÀNG' 
			WHEN d.Type = 2 THEN N'XUẤT HÀNG' END) AS Description
		,'' AS ItemCode
		,SUM(Quantity) AS Quantity
		,'' AS SP
	FROM Doc d	
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		LEFT JOIN Item it ON it.Code = dd.ItemCode
		LEFT JOIN Customer cus ON cus.Code = d.CustomerCode
	WHERE d.IsActive = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 1
	GROUP BY d.Type
	UNION ALL
	SELECT d.DocId
		,DocDate
		,Description
		,ItemCode
		,Quantity
		,'' AS SP
	FROM Doc d	
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 1
) Group3

--BÁO CÁO CHỨNG TỪ THÁNG 1/2021
DECLARE @_ReportType INT = 2
IF @_ReportType = 1
    SELECT *
    FROM Group1
	ORDER BY SP, DocDate ASC

ELSE IF @_ReportType = 2
    SELECT *
    FROM Group2
	ORDER BY ItemCode, DocDate

ELSE IF @_ReportType = 3
    SELECT *
    FROM Group3
	ORDER BY Description, DocDate


DROP TABLE IF EXISTS Group1
DROP TABLE IF EXISTS Group2
DROP TABLE IF EXISTS Group3


-----------------------------------------------------------------------------------------------
--Task 03: 
DECLARE @_DocDate1 DATE = DATEFROMPARTS(2020, 01, 01)
DECLARE @_DocDate2 DATE = DATEFROMPARTS(2023, 01, 01)
DECLARE @_WareHouseList NVARCHAR(20) = 'NVL,HH'
;WITH tbl1 AS
(
	SELECT WareHouseCode
		,ItemCode	
		,SUM(Quantity) AS 'TonDau'
		,0 AS 'Nhap'
		,0 AS 'Xuat'
	FROM OpenWarehouse
	GROUP BY ItemCode, WarehouseCode
	UNION ALL
	SELECT WareHouseCode
		,ItemCode
		,SUM(CASE	WHEN d.Type = 1 AND DocDate < @_DocDate1 THEN Quantity  
					WHEN d.Type = 2 AND DocDate < @_DocDate1 THEN -Quantity END) AS 'TonDau'
		,SUM(CASE	WHEN d.Type = 1 AND DocDate >= @_DocDate1 THEN Quantity ELSE 0 END) AS 'Nhap'
		,SUM(CASE	WHEN d.Type = 2 AND DocDate >= @_DocDate1 THEN Quantity ELSE 0 END) AS 'Xuat'
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		LEFT JOIN Item it ON It.Code = dd.ItemCode
	WHERE d.IsActive = 1 AND DocDate <= @_DocDate2
	GROUP BY ItemCode, WarehouseCode
)
SELECT CASE WHEN GROUPING(WareHouseCode) = 1 THEN '' ELSE WareHouseCode END AS WareHouseCode
	,CASE WHEN GROUPING(ItemCode) = 1 THEN '' ELSE ItemCode END AS ItemCode
	,(CASE	WHEN GROUPING(ItemCode) = 1 THEN N'Tổng ' + wh.Name
			WHEN GROUPING(ItemCode) != 1 THEN ItemCode
			WHEN GROUPING(WarehouseCode) = 1 AND GROUPING(ItemCode) = 1 THEN N'Tổng cộng' END) AS N'Diễn giải'
	,SUM(TonDau) AS 'Open'
	,SUM(Nhap) AS 'In'
	,SUM(Xuat) AS 'Out'
	,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS 'Close'
FROM tbl1
	LEFT JOIN Warehouse wh ON wh.Code = tbl1.WarehouseCode
	LEFT JOIN Item it ON It.Code = tbl1.ItemCode
WHERE WarehouseCode IN (SELECT VALUE FROM string_split(@_WareHouseList, ','))
GROUP BY GROUPING SETS((WarehouseCode, wh.name),(WarehouseCode,ItemCode,wh.name),())
ORDER BY WarehouseCode, ItemCode


-----------------------------------------------------------------------------------------------
--Task 04: 
;WITH pivottbl AS
(
	SELECT *
	FROM
		( 
		SELECT ItemCode
			,(CASE WarehouseCode WHEN 'NVL' THEN 'WareHouseNVL_Qty'
							WHEN 'TP' THEN 'WareHouseTP_Qty'
							WHEN 'HH' THEN 'WareHouseHH_Qty' END) AS Description
			,Quantity AS Number
		FROM Doc d
			LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		WHERE d.IsActive = 1 AND d.Type = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 6
		UNION ALL 
		SELECT ItemCode
			,(CASE WarehouseCode WHEN 'NVL' THEN 'WareHouseNVL_Amt'
							WHEN 'TP' THEN 'WareHouseTP_Amt'
							WHEN 'HH' THEN 'WareHouseHH_Amt' END) AS Description
			,Amount AS Number
		FROM Doc d
			LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
			WHERE d.IsActive = 1 AND d.Type = 1 AND YEAR(DocDate) = 2021 AND MONTH(DocDate) = 6
		) RawData
		PIVOT 
		(
			SUM(Number) FOR Description IN (WareHouseNVL_Qty, WareHouseNVL_Amt, WareHouseTP_Qty, WareHouseTP_Amt, WareHouseHH_Qty,WareHouseHH_Amt)
		) abc
)
SELECT * 
FROM pivottbl
UNION ALL
SELECT N'Tổng cộng'
	,SUM(WareHouseNVL_Qty)
	,SUM(WareHouseNVL_Amt)
	,SUM(WareHouseTP_Qty)
	,SUM(WareHouseTP_Amt)
	,SUM(WareHouseHH_Qty)
	,SUM(WareHouseHH_Amt)
FROM pivottbl
GROUP BY ()











