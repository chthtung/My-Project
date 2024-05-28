-- Bài tập về nhà
-- Buoi05_Bt06: Hiển thị 2 đối tượng còn hiệu lực đến thời điểm hiện tại
-- Câu này em chưa hiểu rõ đề bài lắm ạ :(
SELECT 
	TOP(2) *
FROM
	Customer
WHERE 
	GETDATE() BETWEEN StartDate AND EndDate
	AND IsActive = 1 
	AND Id = RAND(Customer.Id)

-- Buoi05_Bt07: Liệt kê danh sách chứng từ xuất trong năm 2022 cho 5 đối tượng có SL nhập nhiều nhất năm 2021
SELECT 
	Id
	,DocId
	,DocDate
	,DocNo
	,Type
	,CustomerCode
	,WarehouseCode
	,Description
	,IsActive
FROM
	Doc
WHERE 
	Type = 2 
	AND IsActive = 1
	AND CustomerCode IN (
		SELECT 
			TOP 5
			CustomerCode
		FROM
			Doc
			LEFT JOIN DocDetail ON Doc.DocId = DocDetail.DocId
		WHERE
			Doc.IsActive = 1 AND Type =  1 AND YEAR(DocDate) = 2021
		GROUP BY CustomerCode
		ORDER BY SUM(Quantity) DESC
		)
------------------------------------------------------------------------------------------------------------------------------------------------------
-- Buoi05_Bt08: Bảng tổng hợp xuất năm 2022 theo đối tượng, vật tư
-- Danh sách cột: Đối tượng, vật tư, tổng số lượng, tổng tiền.

SELECT 
	(CASE WHEN GROUPING([CustomerCode]) = 1 THEN N'TOTAL OUT ON ITEM' ELSE [CustomerCode] END) AS CustomerCode	
	,(CASE WHEN GROUPING([ItemCode]) = 1 THEN N'TOTAL OUT ON CUSTOMER' ELSE [ItemCode] END) AS ItemCode
	,SUM(Quantity) AS QuantityOUT
	,SUM(Amount) AS AmountOUT
FROM
	Doc
	LEFT JOIN DocDetail ON Doc.DocId = DocDetail.DocId
	LEFT JOIN Item ON DocDetail.ItemCode = Item.Code
WHERE 
	YEAR(DocDate) = 2022 AND Doc.IsActive = 1 AND Doc.Type = 1
GROUP BY CustomerCode, ItemCode WITH CUBE


-- Buoi05_Bt09: Bảng tổng hợp năm 2022 theo từng đối tượng.
-- Danh sách cột: Đối tượng, số lượng chứng từ, tổng số lượng nhập, tổng số lượng xuất.
GO

-- Cách 1: Tạo 3 bảng ảo sau đó JOIN lại với nhau
WITH 
TongNhap AS
	(SELECT
		Doc.CustomerCode
		,SUM(Quantity) AS QuantityIn
	FROM 
		Doc
		LEFT JOIN DocDetail ON Doc.DocId = DocDetail.DocId
	WHERE Doc.IsActive = 1 AND Doc.Type = 1
	GROUP BY CustomerCode
	),
TongXuat AS
	(SELECT
		Doc.CustomerCode
		,SUM(Quantity) AS QuantityOut
	FROM 
		Doc
		LEFT JOIN DocDetail ON Doc.DocId = DocDetail.DocId
	WHERE Doc.IsActive = 1 AND Doc.Type = 2
	GROUP BY CustomerCode
	),
SoLuongDoc AS
	(SELECT 
		Doc.CustomerCode
		,Customer.Name
		,COUNT(Doc.DocID) AS NumberOfDoc
	FROM 
		Customer
		LEFT JOIN Doc ON Customer.Code = Doc.CustomerCode
	GROUP BY Doc.CustomerCode, Customer.Name
	)
SELECT 
	SoLuongDoc.CustomerCode
	,Name
	,NumberOfDoc
	,TongNhap.QuantityIn
	,TongXuat.QuantityOut
FROM
	SoLuongDoc
	LEFT JOIN TongNhap ON TongNhap.CustomerCode = SoLuongDoc.CustomerCode
	LEFT JOIN TongXuat ON TongXuat.CustomerCode = SoLuongDoc.CustomerCode


