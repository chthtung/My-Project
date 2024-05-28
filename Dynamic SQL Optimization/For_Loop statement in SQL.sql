/*Buoi09_Bt01: HIển thị bảng kê chứng từ, thêm cột:
RowNo1: Đánh số dòng sắp xếp theo ngày, số
RowNo2: Đánh số dòng phân đoạn theo khách hàng, sắp xếp số tiền giảm dần
RowNo3: Xếp hạng theo số lượng giảm dần
RowNo4: Chia thành 3 nhóm, phân đoạn theo DocType, sắp xếp theo vật tư */

SELECT * 
	,ROW_NUMBER() OVER (ORDER BY DocDate, DocNo) AS RowNo1
	,ROW_NUMBER() OVER (PARTITION BY CustomerCode ORDER BY Amount) AS RowNo2
	,DENSE_RANK() OVER (ORDER BY Quantity DESC) AS RowNo3
	,NTILE(3) OVER (PARTITION BY d.Type ORDER BY ItemCode) AS RowNo4
FROM Doc d
	LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
WHERE d.IsActive = 1

------------------------------------------------------------------------------------------------------------------
--Buoi09_bt02: Dùng WHILE, hiển thị dòng chứng từ chi tiết có số tiền lớn nhất của từng đối tượng

GO

DROP TABLE IF EXISTS #Cus
SELECT CustomerCode
INTO #Cus
FROM Doc d
	LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
WHERE d.IsActive = 1 
GROUP BY CustomerCode

DECLARE @_CustomerCode NVARCHAR(16)
DECLARE @_DocDate DATE
DECLARE @_ItemCode NVARCHAR(16)
DECLARE @_Amount NUMERIC(18, 2)

WHILE EXISTS(SELECT * FROM #Cus)
BEGIN
	SELECT TOP(1) @_CustomerCode = CustomerCode FROM #Cus

	SELECT TOP(1) @_DocDate = DocDate, @_ItemCode = ItemCode, @_Amount = Amount 
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND CustomerCode = @_CustomerCode
	ORDER BY Amount DESC

	PRINT CONCAT(@_CustomerCode
		,' | ', @_DocDate
		,' | ', @_ItemCode
		,' | ', @_Amount
		)
	DELETE #cus WHERE CustomerCode = @_CustomerCode
END
DROP TABLE #Cus


---------------------------------------------------------------------------------------------------------------------------
GO --Buoi09_Bt03: 

--Khai báo các giá trị biến cần lấy
DECLARE @_CustomerCode NVARCHAR(16)
DECLARE @_DocDate DATE
DECLARE @_ItemCode NVARCHAR(16)
DECLARE @_Amount NUMERIC(18, 2)

--Khai báo con trỏ (Trỏ đến các CustomerCode)
DECLARE MyCursor CURSOR FOR 
SELECT CustomerCode
FROM Doc d
	LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
WHERE d.IsActive = 1 
GROUP BY CustomerCode

OPEN MyCursor --Bắt đầu chạy Con trỏ

FETCH NEXT FROM MyCursor INTO @_CustomerCode --Trỏ con trỏ đến Row đầu tiên

WHILE (@@FETCH_STATUS = 0) --Khi con trỏ còn hiệu lực 
BEGIN

	SELECT TOP(1) @_DocDate = DocDate, @_ItemCode = ItemCode, @_Amount = Amount 
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1 AND CustomerCode = @_CustomerCode
	ORDER BY Amount DESC

	PRINT CONCAT(@_CustomerCode
		,' | ', @_DocDate
		,' | ', @_ItemCode
		,' | ', @_Amount
		)
	FETCH NEXT FROM MyCursor INTO @_CustomerCode --Chuyển con trỏ xuống dòng kế tiếp
END 
CLOSE MyCursor --Đóng con trỏ
DEALLOCATE MyCursor --Xóa con trỏ




-----------------------------------------------------------------------------------------------------------------------------
GO --Buoi09_Bt04: 
SELECT DocId, DocDate, DocNo, Type, CustomerCode, WarehouseCode, Description, RowId, ItemCode, Quantity, UnitCost, Amount
FROM (
	SELECT d.DocId, DocDate, DocNo, Type, CustomerCode, WarehouseCode, Description, RowId, ItemCode, Quantity, UnitCost, Amount
		,RANK() OVER (PARTITION BY CustomerCode ORDER BY Amount DESC) CusRank
	FROM Doc d
		LEFT JOIN DocDetail dd ON d.DocId = dd.DocId
	WHERE d.IsActive = 1
	) abcdef
WHERE CusRank = 1