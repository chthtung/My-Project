/* Buoi06_Bt03: Báo cáo bảng kê chứng từ tổng hợp theo đối tượng
Dòng tổng hợp sắp xếp tăng dần theo CustomerCode
Dòng chi tiết sắp xếp giảm dần theo DocDate, DocNo
*/
GO --Cách 1
SELECT d.DocDate
	,d.DocNo
	,d.Description
	,dd.ItemCode
	,it.Name AS ItemName
	,dd.Quantity
	,dd.UnitCost
	,dd.Amount
	,d.CustomerCode
FROM dbo.Doc d
	LEFT JOIN dbo.DocDetail dd ON dd.DocId = d.DocId
	LEFT JOIN dbo.Item it ON dd.ItemCode = it.Code
WHERE d.IsActive = 1
UNION all
SELECT DATEADD(DD,1,MAX(d.DocDate)),'', d.CustomerCode + ': ' + ISNULL(MAX(cus.Name), '') AS Description, NULL, NULL, NULL, NULL, NULL, d.CustomerCode
FROM dbo.Doc d
		LEFT JOIN dbo.Customer cus ON cus.Code = d.CustomerCode
GROUP BY d.CustomerCode
ORDER BY CustomerCode,  d.DocDate DESC, d.DocNo DESC

GO -- Cách 2
DROP TABLE IF EXISTS #Buoi06_Bt03
SELECT
	d.DocDate	
	,d.DocNo
	,d.Description
	,dd.ItemCode
	,it.Name AS ItemName
	,dd.Quantity
	,dd.UnitCost
	,dd.Amount
	,d.CustomerCode
INTO #Buoi06_Bt03
FROM 
	Doc d
	LEFT JOIN DocDetail dd ON dd.DocId = d.DocId
	LEFT JOIN Item it ON dd.ItemCode = it.Code
WHERE d.IsActive = 1

INSERT INTO #Buoi06_Bt03 (DocDate, DocNo, Description, ItemCode, ItemName, Quantity, UnitCost, Amount, CustomerCode)
	SELECT DATEFROMPARTS(9999,12,31),'', d.CustomerCode + ': ' + ISNULL(MAX(cus.Name), '') AS Description, NULL, NULL, NULL, NULL, NULL, d.CustomerCode 
	FROM #Buoi06_Bt03 d
		LEFT JOIN Customer cus ON cus.Code = d.CustomerCode
	GROUP BY CustomerCode

SELECT * 
FROM #Buoi06_Bt03
ORDER BY CustomerCode,  DocDate DESC, DocNo DESC
DROP TABLE #Buoi06_Bt03

-- Buoi06_Bt04: Báo cáo nhập xuất tồn như Buoi06_Bt02 bằng 1 câu lệnh
GO -- Cách 1:
SELECT W.ItemCode
	,CASE WHEN GROUPING(W.ItemCode) = 1 THEN N'Tổng cộng' ELSE MAX(it.Name) END AS ItemName
	,SUM(W.TonDau) AS TonDau
	,SUM(W.Nhap) AS Nhap
	,SUM(W.Xuat) AS Xuat
	,SUM(W.TonDau+W.Nhap-W.Xuat) AS TonCuoi
FROM
	(SELECT ItemCode
		,SUM(Quantity) AS TonDau
		,0 AS Nhap
		,0 AS Xuat
	FROM dbo.OpenWarehouse
	GROUP BY ItemCode
	UNION ALL
	SELECT dd.ItemCode
		,0 AS TonDau
		, SUM(CASE WHEN d.TYPE = 1 THEN	Quantity ELSE 0 END) AS Nhap
		, SUM(CASE WHEN d.TYPE <> 1 THEN Quantity ELSE 0 END) AS xuat
	FROM dbo.Doc d
		LEFT JOIN dbo.DocDetail dd ON dd.DocId = d.DocId
	WHERE d.IsActive = 1
	GROUP BY dd.ItemCode) AS W
	LEFT JOIN dbo.Item it ON w.ItemCode=it.Code
GROUP BY GROUPING SETS ((W.ItemCode),())



-- Buoi06_Bt05: Báo cáo nhập xuất tồn trong khoảng @_Ngay1 và @_Ngay2. Cột tồn đầu là SL tồn đến đầu @_Ngay1

DROP TABLE IF EXISTS #Buoi06_Bt05
DECLARE @_Ngay1 DATE = DATEFROMPARTS(2020,1,1)
DECLARE @_Ngay2 DATE = DATEFROMPARTS(2024,12,31)
SELECT ItemCode
	,SUM(TonDau) AS TonDau
	,SUM(Nhap) AS Nhap
	,SUM(Xuat) AS Xuat
	,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonCK
INTO #Buoi06_Bt05
FROM
(
	SELECT 
		ItemCode
		,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonDau
		,0 AS Nhap
		,0 AS Xuat
	FROM
		(SELECT o.ItemCode
			,SUM(o.Amount) AS TonDau
			,0 AS Nhap
			,0 AS Xuat
		FROM OpenWarehouse o
		GROUP BY o.ItemCode
		UNION ALL
		SELECT dd.ItemCode
			, 0 AS TonDau
			,SUM(CASE Type WHEN 1 THEN Quantity ELSE 0 END) AS Nhap
			,SUM(CASE Type WHEN 2 THEN Quantity ELSE 0 END) AS Xuat
		FROM Doc d
			LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		WHERE d.IsActive = 1 AND DocDate <= @_Ngay1
		GROUP BY ItemCode) AS RawTable
	GROUP BY ItemCode
	UNION ALL
	SELECT dd.ItemCode
		,0 AS TonDau
		,SUM(CASE WHEN Type = 1 THEN dd.Quantity ELSE 0 END) AS Nhap
		,SUM(CASE WHEN Type = 2 THEN dd.Quantity ELSE 0 END) AS Xuat
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND (DocDate BETWEEN @_Ngay1 AND @_Ngay2)
	GROUP BY dd.ItemCode
) AS MainTable
GROUP BY ItemCode

SELECT * FROM #Buoi06_Bt05
UNION ALL
SELECT N'Tổng cộng' AS ItemCode
	,SUM(TonDau) AS TonDau
	,SUM(Nhap) AS Nhap
	,SUM(Xuat) AS Xuat
	,SUM(TonCK) AS TonCK
FROM #Buoi06_Bt05

