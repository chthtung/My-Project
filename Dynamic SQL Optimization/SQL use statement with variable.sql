
-- BÀI TẬP VỀ NHÀ BUỔI II	
-- Họ và tên: Chu Thanh Tùng	
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Buoi02_Bt05: Cho 1 chuỗi cách nhau nhiều dấu cách N'  Nguyễn   Du       Thúy       Kiều   '. Viết câu lệnh SQL để chuẩn lại chuỗi này các từ cách nhau 1 dấu cách.

-- Cách 1:
GO
DECLARE @_Str NVARCHAR(128) = N'  Nguyễn   Du       Thúy       Kiều   ' 
SELECT LTRIM(RTRIM(REPLACE(@_Str, '  ', ''))) AS HoTen

-- Cách 2:
GO
DECLARE @_Str NVARCHAR(128) = N'  Nguyễn   Du       Thúy       Kiều   ' 
DECLARE @_Strcmp NVARCHAR(128) = LTRIM(RTRIM(@_Str)),
		@_Pos INT = 0
WHILE @_Pos < LEN(@_Strcmp)
	BEGIN
		IF SUBSTRING(@_Strcmp, @_Pos, 1) = ' '
			IF	SUBSTRING(@_Strcmp, @_Pos + 1, 1) = ' '
					SET @_Strcmp = STUFF(@_Strcmp, @_Pos, 1, '')
			ELSE	SET @_Pos = @_Pos + 1;
		ELSE SET @_Pos = @_Pos + 1;
	END;

SELECT @_Strcmp AS HoTen

-- Cách 3: Xóa hết tất cả khoảng trắng đi. Tiếp đó, thêm kí tự space vào trước kí tự nào viết hoa
DECLARE @Name NVARCHAR(MAX) = N'  Nguyễn   Du       Thúy       Kiều   ';
DECLARE @_i int, @_j int, @check1 varchar(1);
SET @Name= REPLACE(@Name, ' ', '')
SET @_i = 2
SET @_j = LEN(@Name)
WHILE (@_i < @_j)
	BEGIN
		SET @check1 = SUBSTRING(@Name, @_i, 1)
		IF (ASCII(@check1) >=65 and ASCII(@check1) <= 90 ) 
			BEGIN 
				SET @Name = STUFF(@Name, @_i  , 0, ' ')
				SET @_i+= 1
				SET @_j+=1
				PRINT(@Name)
			END
		SET @_i+=1; 
	END
PRINT(@Name)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Buoi02_Bt06: Hiển thị ký tự đầu tiên viết hoa và ký tự khác viết thường trong chuỗi tên N'Hải hòa vinH lê nguyên quang'

GO
DECLARE @_Str NVARCHAR(MAX) = N'Hải hòa vinH lê nguyên quang'
DECLARE @_Pos INT = 0,
		@_Strcmp NVARCHAR(MAX) = LOWER(@_Str)
WHILE @_Pos < LEN(@_Strcmp)
BEGIN
	IF SUBSTRING(@_Strcmp,@_Pos,1) = ' '
	SET @_Strcmp = STUFF(@_Strcmp, @_Pos + 1, 1, UPPER(SUBSTRING(@_Strcmp, @_Pos + 1, 1))) 
	SET @_Pos = @_Pos + 1
END;
SELECT @_Strcmp AS ChuanHoa

GO

-- Bài tập về nhà
-- Buoi02_Bt05: Cho 1 chuỗi cách nhau nhiều dấu cách N'  Nguyễn du   Thúy     Kiều   '. Viết câu lệnh SQL để chuẩn lại chuỗi này các từ cách nhau 1 dấu cách.
-- Cách không dùng vòng lặp
DECLARE @_Str NVARCHAR(MAX) = N'  Nguyễn du  Thúy       Kiều    Thúy     Vân   '
PRINT @_Str

SET @_Str = LTRIM(RTRIM(@_Str))
SET @_Str = REPLACE(@_Str, '  ',' _')
PRINT @_Str
SET @_Str = REPLACE(@_Str, '_ ','')
PRINT @_Str
SET @_Str = REPLACE(@_Str, '_','') 
PRINT @_Str

GO

--C2: 
SELECT TRIM(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@_X, CHAR(13), ''), CHAR(10), ''),' ', CHAR(10) + CHAR(13)), CHAR(13) + CHAR(10), ''), CHAR(10) + CHAR(13), ' ')) AS Result

-- Buoi02_Bt06: Hiển thị ký tự đầu tiên viết hoa và ký tự khác viết thường trong chuỗi tên N'Hải hòa vinH lê nguyên quang'
-- Cách 1: Không dùng vòng lặp
DECLARE @_Str NVARCHAR(MAX) = N'Hải hòa vinH lê nguyên quang'
SET @_Str = LOWER(@_Str)

DECLARE @_StrExec NVARCHAR(MAX)
SET @_StrExec = 
'DECLARE @_Str1 NVARCHAR(MAX), @_Str2 NVARCHAR(MAX)=''''
SET @_Str1 = N''' 
+ REPLACE(@_Str, ' ', '''; SET @_Str2 = @_Str2 + STUFF(@_Str1, 1, 1, UPPER(LEFT(@_Str1, 1))) + SPACE(1);
SET @_Str1 = N''') 
+ '''; SET @_Str2 = @_Str2 + STUFF(@_Str1, 1, 1, UPPER(LEFT(@_Str1, 1)))
PRINT @_Str2
'
PRINT @_StrExec
EXEC (@_StrExec)

-- Cách 2: Không dùng vòng lặp
-- Database 2016 version 130 trở lên
-- SELECT compatibility_level FROM sys.databases WHERE name = DB_NAME()
SELECT STUFF(
    (SELECT SPACE(1) + STUFF(LOWER(Value), 1, 1, UPPER(LEFT(Value, 1)))
	FROM STRING_SPLIT(@_Str,' ')
	FOR XML PATH('')
	)
	,1,1,'')
	
	
-- Database 2017 version 14 trở lên
-- SELECT compatibility_level FROM sys.databases WHERE name = DB_NAME()
SELECT STRING_AGG(CONVERT(NVARCHAR(MAX),
		STUFF(LOWER(Value), 1, 1, UPPER(LEFT(Value, 1))))
		, ' ')
FROM STRING_SPLIT(@_Str,' ')

GO

DECLARE @_Str NVARCHAR(MAX) = N'Hải hòa vinH lê nguyên quang'
SET @_Str = LOWER(@_Str)
SELECT * FROM STRING_SPLIT(@_Str,' ')
