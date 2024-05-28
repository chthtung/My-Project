/* Dựa trên số liệu từ chứng từ, PIVOT ra
bảng có dòng là ngày, cột là các mã vật tư, giá trị là tổng số lượng
Thêm dòng tổng cộng
*/
DECLARE @_Itemlist NVARCHAR(MAX) 
SELECT @_Itemlist = STRING_AGG(Code, ',') FROM Item

DECLARE @_Str NVARCHAR(MAX) = N'
;WITH RAW AS
(
	SELECT * FROM
	(
		SELECT DocDate
			,ItemCode
			,Quantity
		FROM Doc d
			LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	) tbl1
		PIVOT (SUM(Quantity) FOR ItemCode IN ('+ @_Itemlist +')) AS PivotTbl
)
,total AS
(
		SELECT * FROM 
	(
		SELECT Null AS DocDate
			,ItemCode
			,SUM(CASE WHEN d.Type = 1 THEN Quantity ELSE 0 END) - SUM(CASE WHEN d.Type = 2 THEN Quantity ELSE 0 END)  AS Quantity
		FROM Doc d
			LEFT JOIN DocDetail dd ON d.DocId = dd.DocID
		GROUP BY ItemCode
	) tbl5
	PIVOT (SUM(Quantity) FOR ItemCode IN ('+ @_Itemlist +')) AS PivotTbl
) 
SELECT * FROM RAW 
UNION ALL
SELECT * FROM total
'
EXEC sp_executesql @_Str
	,N'@_Itemlist NVARCHAR(MAX)'
	,@_Itemlist = @_Itemlist

-- Dòng giá trị DocDate = NULL là Tổng giá trị nhập xuất

--Buoi07_Bt04: Từ bảng Pivot ở bài 2, UNPIVOT ra  bảng ban đầu gồm DocDate, ItemCode, Quantity
GO

--Tạo ra bảng PIVOT ở bài 2
DROP TABLE IF EXISTS TestCase
SELECT * 
INTO TestCase
FROM 
(
	SELECT * FROM
		(SELECT DocDate, Quantity, ItemCode
		FROM Doc d
			LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		) tbl
	PIVOT (
		SUM(Quantity)
		FOR ItemCode IN (A92, A95, DIESEL, HH01, HH02, HH03, NVL01, NVL02, NVL03, TP01, TP02, TP03)
	) AS PivotTbl
) abcdefg
SELECT * FROM TestCase

--Dynamic UNPIVOT bảng vừa rồi
DECLARE @_Itemlist NVARCHAR(MAX) 
SELECT @_Itemlist = STRING_AGG(Code, ',') FROM Item

DECLARE @_Str NVARCHAR(MAX) = N'
SELECT * FROM TestCase
UNPIVOT
(
    Quantity FOR ItemCode IN ('+@_ItemList+')
) AS UnpivotTbl
ORDER BY DocDate
'
EXEC sp_executesql @_Str
	,N'@_Itemlist NVARCHAR(MAX)'
	,@_Itemlist = @_Itemlist

--UNPIVOT cứng bảng TestCase
GO

SELECT DocDate, ItemCode, Quantity FROM TestCase
UNPIVOT
(
    Quantity 
	FOR ItemCode IN (A92, A95, DIESEL, HH01, HH02, HH03, NVL01, NVL02, NVL03, TP01, TP02, TP03)
) AS UnpivotTbl
ORDER BY DocDate

