-- CHU THANH TÙNG - ĐẠI HỌC KINH TẾ QUỐC DÂN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Buoi03_Bt07: Trong năm 2021, tìm tất cả các ngày là thứ hai, ngày 01 (Không dùng DATENAME)
-- Cách 1: 
SELECT DATEFROMPARTS(2021, month_number, 1) AS monday_dates
FROM	(
		SELECT number AS month_number
		FROM master..spt_values
		WHERE type = 'P' AND number BETWEEN 1 AND 12
		) AS months
WHERE DATEPART(WEEKDAY, DATEFROMPARTS(2021, month_number, 1)) = 2

-- Cách 2:
WITH numbers AS (
	SELECT 1 AS month_numbers
	UNION ALL
	SELECT month_numbers + 1
	FROM numbers
	WHERE month_numbers < 12
	)
SELECT DATEFROMPARTS(2021, month_numbers, 1) AS monday_dates
FROM numbers
WHERE DATEPART(WEEKDAY, DATEFROMPARTS(2021, month_numbers, 1)) = 2

-- Cách 3: Tạo ra một biến dạng bảng gồm các ngày trong năm sau đó tính như bình thường
DECLARE @31122021 DATE = DATEFROMPARTS(2021, 12, 31)
DECLARE @01012021 DATE = DATEFROMPARTS(2021, 1, 1)
DECLARE @day DATE = @01012021
DECLARE @result TABLE (Ngay DATE)
WHILE @day BETWEEN @01012021 AND @31122021 
BEGIN	INSERT INTO @result VALUES (@day)
		SET @day = DATEADD(DAY, 1, @day)
END;
SELECT * FROM @result

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Buoi03_Bt08: Trong năm 2021, tìm tất cả các ngày là chủ nhật lần thứ 3 trong tháng (Không dùng DATENAME).
-- Cách 1: 
WITH mnumbers AS (
	SELECT 1 AS month_numbers
	UNION ALL
	SELECT month_numbers + 1
	FROM mnumbers
	WHERE month_numbers < 12
	),
	dnumbers AS (
	SELECT 1 AS day_numbers
	UNION ALL
	SELECT day_numbers + 1
	FROM dnumbers
	WHERE day_numbers < 28
	)
SELECT DATEFROMPARTS(2021, month_numbers, day_numbers) AS sunday_dates
FROM dnumbers, mnumbers
WHERE	day_numbers BETWEEN 15 AND 21
AND		DATEPART(DW,DATEFROMPARTS(2021, month_numbers, day_numbers)) = 1

-- Cách 2: 
WITH mnumbers AS (
	SELECT 1 AS month_numbers
	UNION ALL
	SELECT month_numbers + 1
	FROM mnumbers
	WHERE month_numbers < 12
	)
SELECT DATEADD(DAY, 22 - DATEPART(DW,DATEFROMPARTS(2021, month_numbers, 1)),DATEFROMPARTS(2021, month_numbers, 1))
FROM mnumbers
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Buoi03_Bt09: Trong thế kỷ 21, tìm các năm nhuận.
-- Cách 1: 
	DECLARE @year INT = 2001
	WHILE @year < 2100 
	BEGIN 
		IF @year%4=0 AND @year%100!=0
		SELECT @year AS Nam_nhuan
		SET @year = @year + 1
	END;

-- Cách 2: Truy vấn độc lập
	WITH numbers AS (
	  SELECT 2000 AS year_number
	  UNION ALL
	  SELECT year_number + 1
	  FROM numbers
	  WHERE year_number < 2099
	)
	SELECT year_number AS Nam_nhuan
	FROM numbers
	WHERE year_number % 4 = 0 AND year_number % 100 != 0
