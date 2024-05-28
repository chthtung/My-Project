--Buoi07:
/* Buoi07_Bt01: Cho biến @_Ngay DATE = DATEFROMPARTS(2022, 2, 10). Chuyển @_Ngay thành dạng chuỗi, định dạng dd/mm/yyyy
Sau đó dùng chuỗi này để chuyển ngược lại thành dạng date.
Lưu ý dùng càng nhiều cách càng tốt (Cast, Convert, Format,...)
*/

DECLARE @_Ngay DATE = DATEFROMPARTS(2022, 2, 10);
DECLARE @_NgayChuoi VARCHAR(10);
DECLARE @_NgayChuyenDoi DATE;

-- Cách 1: CAST
SET @_NgayChuoi = CAST(FORMAT(@_Ngay, 'dd/MM/yyyy') AS VARCHAR(10));
SET @_NgayChuyenDoi = CAST(@_NgayChuoi AS DATE);

SELECT N'Ngày ' + @_NgayChuoi AS NgayChuoi, @_NgayChuyenDoi AS NgayChuyenDoi;

-- Cách 2: CONVERT
SET @_NgayChuoi = CONVERT(VARCHAR(10), @_Ngay, 103);
SET @_NgayChuyenDoi = CONVERT(DATE, @_NgayChuoi, 103);

SELECT N'Ngày ' + @_NgayChuoi AS NgayChuoi, @_NgayChuyenDoi AS NgayChuyenDoi;

-- Cách 3: FORMAT
SET @_NgayChuoi = FORMAT(@_Ngay, 'dd/MM/yyyy');
SET @_NgayChuyenDoi = CONVERT(DATE, @_NgayChuoi, 103);

SELECT N'Ngày ' + @_NgayChuoi AS NgayChuoi, @_NgayChuyenDoi AS NgayChuyenDoi;

-- CÁch 4: Dùng DATEPART tách ngày/tháng/năm sau đó ghép lại thành chuỗi
SET @_NgayChuoi = CONCAT(DATEPART(DAY, @_Ngay), '/', DATEPART(MONTH, @_Ngay), '/', DATEPART(YEAR, @_Ngay));
SET @_NgayChuyenDoi = CONVERT(DATE, @_NgayChuoi, 103);

SELECT N'Ngày ' + @_NgayChuoi AS NgayChuoi, @_NgayChuyenDoi AS NgayChuyenDoi;
-------------------------------------------------------------------------------------------------------------------------------------------------
--Buoi07_bT02: Báo cáo nhập xuất tồn trong khoảng @_Ngay1 và @_Ngay2 bằng cách khởi tạo chuỗi @_Str, gán giá trị cho nó, cuối cùng dùng EXEC(@_Str)
-- (Lưu ý cách chuyển đổi ngày đúng trong mọi môi trường) 
DECLARE @_NgayBatDau DATE = DATEFROMPARTS(2020, 01, 01)
DECLARE @_NgayKetThuc DATE = DATEFROMPARTS(2023, 01, 01)

DECLARE @_Str NVARCHAR(MAX) 
SET @_Str = N'
DECLARE @_Ngay1 DATE = DATEFROMPARTS('+STR(YEAR(@_NgayBatDau),4) + ',' + STR(MONTH(@_NgayBatDau),2) + ',' + STR(DAY(@_NgayBatDau),2)  +N')
DECLARE @_Ngay2 DATE = DATEFROMPARTS('+STR(YEAR(@_NgayKetThuc),4) + ',' + STR(MONTH(@_NgayKetThuc),2) + ',' + STR(DAY(@_NgayKetThuc),2)  +N')
	;WITH Tbl1 AS
		(
		SELECT ItemCode
			,SUM(Quantity) AS TonDau 
			,0 AS Nhap
			,0 AS Xuat
		FROM OpenWarehouse
		GROUP BY ItemCode
		UNION ALL
		SELECT ItemCode
			,SUM(CASE	WHEN Type = 1 AND DocDate < @_Ngay1 THEN Quantity
						WHEN Type = 2 AND DocDate < @_Ngay1 THEN -Quantity END) AS TonDau
			,SUM(CASE	WHEN Type = 1 AND DocDate >=@_Ngay1 THEN Quantity ELSE 0 END) AS Nhap
			,SUM(CASE	WHEN Type = 2 AND DocDate >=@_Ngay1 THEN Quantity ELSE 0 END) AS Xuat
		FROM Doc d
			LEFT JOIN DocDetail dd ON dd.DocId = d.DocId
		WHERE d.IsActive = 1 AND DocDate <= @_Ngay2
		GROUP BY ItemCode
		)
	SELECT CASE WHEN GROUPING(ItemCode) = 1 THEN N'' Tổng cộng '' ELSE ItemCode END AS TonDau
		,SUM(TonDau) AS TonDau
		,SUM(Nhap) AS Nhap
		,SUM(Xuat) AS Xuat
		,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonCK
	FROM Tbl1
	GROUP BY GROUPING SETS((ItemCode), ())
'
EXEC(@_Str)

-------------------------------------------------------------------------------------------------------------------------------------------------
/* Buoi07_Bt03: Báo cáo nhập xuất tồn trong khoảng ngày @_Ngay1 và @_Ngay2 bằng cách khởi tạo chuỗi @_Str, gán giá trị cho nó, cuối cùng dùng EXEC sp_executesql.
@_Ngay1 và @_Ngay2 truyền giá trị tại sp_executesql.
*/
GO

DECLARE @_NgayBatDau DATE = DATEFROMPARTS(2020, 01, 01)
DECLARE @_NgayKetThuc DATE = DATEFROMPARTS(2023, 01, 01)


DECLARE @_Str NVARCHAR(MAX) 
SET @_Str = N'
	;WITH Tbl1 AS
		(
		SELECT ItemCode
			,SUM(Quantity) AS TonDau
			,0 AS Nhap
			,0 AS Xuat
		FROM OpenWarehouse
		GROUP BY ItemCode
		UNION ALL
		SELECT ItemCode
			,SUM(CASE	WHEN Type = 1 AND DocDate < @_Ngay1 THEN Quantity
						WHEN Type = 2 AND DocDate < @_Ngay1 THEN -Quantity END) AS TonDau
			,SUM(CASE	WHEN Type = 1 AND DocDate >=@_Ngay1 THEN Quantity ELSE 0 END) AS Nhap
			,SUM(CASE	WHEN Type = 2 AND DocDate >=@_Ngay1 THEN Quantity ELSE 0 END) AS Xuat
		FROM Doc d
			LEFT JOIN DocDetail dd ON dd.DocId = d.DocId
		WHERE d.IsActive = 1 AND DocDate <= @_Ngay2
		GROUP BY ItemCode
		)
	SELECT CASE WHEN GROUPING(ItemCode) = 1 THEN N'' Tổng cộng '' ELSE ItemCode END AS TonDau
		,SUM(TonDau) AS TonDau
		,SUM(Nhap) AS Nhap
		,SUM(Xuat) AS Xuat
		,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonCK
	FROM Tbl1
	GROUP BY GROUPING SETS((ItemCode), ())
'
EXEC sp_executesql @_Str
	,N'@_Ngay1 DATE, @_Ngay2 DATE' --Khai báo các tham số dùng trong dynamic querry
	,@_Ngay1 = @_NgayBatDau -- Khai báo giá trị biến 1 
	,@_Ngay2 = @_NgayKetThuc -- Khai báo giá trị biến 2

---------------------------------------------------------------------------------------------------------------------
/* Buoi07_Bt04: BÁo cáo nhập xuất tồn trong khoảng @_Ngay1 và @_Ngay2, nhóm theo kho, vật tư
WarehouseCode	ItemCode	Diễn giải	TonDau		Nhap	Xuat	TonCuoi
.....			...			...			...			...		...		...
							Tổng cộng	...			...		...		...
*/

-- Cách 1: 
GO
DECLARE @_Ngay1 DATE = DATEFROMPARTS(2020, 01, 01)
DECLARE @_Ngay2 DATE = DATEFROMPARTS(2023, 01, 01)

;WITH tbl1 AS
(
	SELECT WarehouseCode
		,ItemCode	
		,SUM(Quantity) AS TonDau
		,0 AS Nhap
		,0 AS Xuat
			FROM OpenWarehouse
			GROUP BY ItemCode, WarehouseCode
	UNION ALL
	SELECT WarehouseCode
		,ItemCode
		,SUM(CASE	WHEN d.Type = 1 AND DocDate < @_Ngay1 THEN Quantity  
					WHEN d.Type = 2 AND DocDate < @_Ngay1 THEN -Quantity END) AS TonDau
		,SUM(CASE	WHEN d.Type = 1 AND DocDate >= @_Ngay1 THEN Quantity ELSE 0 END) AS Nhap
		,SUM(CASE	WHEN d.Type = 2 AND DocDate >= @_Ngay1 THEN Quantity ELSE 0 END) AS Xuat
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
		LEFT JOIN Item it ON It.Code = dd.ItemCode
	WHERE d.IsActive = 1 AND DocDate <= @_Ngay2
	GROUP BY ItemCode, WarehouseCode
)
SELECT CASE WHEN GROUPING(WareHouseCode) = 1 THEN '' ELSE WareHouseCode END AS WareHouseCode
	,CASE WHEN GROUPING(ItemCode) = 1 THEN '' ELSE ItemCode END AS ItemCode
	,(CASE	WHEN GROUPING(ItemCode) = 1 THEN N'Tổng cộng ' + wh.Name
			WHEN GROUPING(ItemCode) != 1 THEN ItemCode
			WHEN GROUPING(WarehouseCode) = 1 AND GROUPING(ItemCode) = 1 THEN N'Tổng cộng' END) AS N'Diễn giải'
	,SUM(TonDau) AS TonDau
	,SUM(Nhap) AS Nhap
	,SUM(Xuat) AS Xuat
	,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonCK
FROM tbl1
	LEFT JOIN Warehouse wh ON wh.Code = tbl1.WarehouseCode
	LEFT JOIN Item it ON It.Code = tbl1.ItemCode
GROUP BY GROUPING SETS((WarehouseCode, wh.name),(WarehouseCode,ItemCode,wh.name),())
ORDER BY WarehouseCode, ItemCode

GO -- Cách 2: 
DECLARE @_Ngay1 DATE = DATEFROMPARTS(2020, 01, 01)
DECLARE @_Ngay2 DATE = DATEFROMPARTS(2023, 01, 01)

;WITH tbl1 AS
(
	SELECT WarehouseCode
		,ItemCode
		,SUM(Quantity) AS TonDau
		,0 AS Nhap
		,0 AS Xuat
			FROM OpenWarehouse
			GROUP BY ItemCode, WarehouseCode
	UNION ALL
	SELECT WarehouseCode
		,ItemCode
		,SUM(CASE	WHEN d.Type = 1 AND DocDate < @_Ngay1 THEN Quantity  
					WHEN d.Type = 2 AND DocDate < @_Ngay1 THEN -Quantity END) AS TonDau
		,SUM(CASE	WHEN d.Type = 1 AND DocDate >= @_Ngay1 THEN Quantity ELSE 0 END) AS Nhap
		,SUM(CASE	WHEN d.Type = 2 AND DocDate >= @_Ngay1 THEN Quantity ELSE 0 END) AS Xuat
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND DocDate <= @_Ngay2
	GROUP BY ItemCode, WarehouseCode
)
SELECT CASE WHEN GROUPING(WareHouseCode) = 1 THEN '' ELSE WareHouseCode END AS WareHouseCode
	,CASE WHEN GROUPING(ItemCode) = 1 THEN '' ELSE ItemCode END AS ItemCode
	,(CASE	WHEN GROUPING(ItemCode) = 1 THEN N'Tổng cộng ' + Name
			WHEN GROUPING(ItemCode) != 1 THEN Name END) AS N'Diễn giải'
	,SUM(TonDau) AS TonDau
	,SUM(Nhap) AS Nhap
	,SUM(Xuat) AS Xuat
	,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonCK
FROM tbl1
	LEFT JOIN Warehouse wh ON wh.Code = tbl1.WarehouseCode
GROUP BY GROUPING SETS((WarehouseCode, Name),(WarehouseCode,Name,ItemCode))
UNION ALL 
SELECT ''
	,''
	,N'Tổng cộng'
	,SUM(TonDau) AS TonDau
	,SUM(Nhap) AS Nhap
	,SUM(Xuat) AS Xuat
	,SUM(TonDau) + SUM(Nhap) - SUM(Xuat) AS TonCK
FROM tbl1
ORDER BY WarehouseCode, ItemCode



