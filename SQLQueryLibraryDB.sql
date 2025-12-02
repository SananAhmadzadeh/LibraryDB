--Library database-i qurursunuz


CREATE DATABASE LibraryDB

USE LibraryDB


CREATE TABLE Authors
(
   ID INT PRIMARY KEY IDENTITY,
   [Name] NVARCHAR(50) NOT NULL,
   Surname NVARCHAR(50) NOT NULL
);

CREATE TABLE Books
(
   ID INT PRIMARY KEY IDENTITY,
   AuthorID INT FOREIGN KEY REFERENCES Authors(ID),
   [Name] NVARCHAR(100) NOT NULL 
   CHECK(LEN([Name]) <= 100 and LEN([Name]) >=2),
   [Page Count] INT 
   CHECK( [Page Count] > 10)
);

-- Authors cədvəli
INSERT INTO Authors ([Name], Surname) VALUES
('Əli', 'Hüseynov'),
('Nizami', 'Gəncəvi'),
('Cəlil', 'Məmmədquluzadə'),
('Sabir', 'Hüseynov'),
('Elçin', 'Hüseyn');

-- Books cədvəli
INSERT INTO Books (AuthorID, [Name], [Page Count]) VALUES
(1, 'Səhərdən Gecəyə', 120),
(2, 'Xəmsə', 250),
(3, 'Ölülər', 180),
(4, 'Hophopnamə', 90),
(5, 'Gecikmiş Söz', 150),
(1, 'Yeni Hekayələr', 200),
(5, 'Seçilmiş Hekayələr', 220);

-- (one to many realtion) Id,Name,PageCount ve
-- AuthorFullName columnlarinin valuelarini
--qaytaran bir VIEW yaradin

CREATE VIEW GetAllInfoAuthorAbout

AS

SELECT 
     A.Name + ' ' + A.Surname AS [Author FullName],
     B.ID AS [BookID],
     B.Name AS [Book Name],
     B.[Page Count] AS [Page Count]
FROM Authors AS A
JOIN Books AS B ON B.AuthorID = A.ID;


--Gonderilmis axtaris deyirene gore hemin axtaris
-- deyeri Boook.name ve ya Author.Name olan Book-lari
-- Id,Name,PageCount,AuthorFullName columnlari seklinde
-- gosteren procedure yazin

CREATE PROCEDURE SearchingAllBooksAndAuthor @Search NVARCHAR(100)

AS

BEGIN

    SELECT 
        A.Name + ' ' + A.Surname AS [AuthorFullName],
        B.ID AS [BookID],
        B.Name AS [BookName],
        B.[Page Count] AS [PageCount]
    FROM Authors AS A
    JOIN Books AS B ON B.AuthorID = A.ID
    WHERE A.Name LIKE '%' + @Search + '%'
    OR A.Surname LIKE '%' + @Search + '%'
    OR B.Name LIKE '%' + @Search + '%'

END;

EXEC SearchingAllBooksAndAuthor @Search = 'Nizami'

--Bir Function yaradin.MinPageCount parametri qebul etsin.Default deyeri 10 olsun;
--PageCount gonderilmis deyerden boyuk olan kitablarin sayini qaytarsin
CREATE FUNCTION GetPageCountAllBooks (@MinPageCount INT = 10)
RETURNS TABLE
AS 
RETURN
(
    SELECT 
        B.ID AS BookID,
        B.Name AS BookName,
        B.[Page Count] AS PageCount,
        A.Name + ' ' + A.Surname AS AuthorFullName
    FROM Books AS B
    JOIN Authors AS A ON B.AuthorID = A.ID
    WHERE B.[Page Count] > @MinPageCount
);

SELECT * FROM GetPageCountAllBooks(150);


--DeletedBooks table yaradin
--trigger yaradirsiz.
--Books tablesindən kitab silinən zaman silinmiş kitab deleted books tablesinə düşsün
CREATE TABLE DeletedBooks
(
   ID INT PRIMARY KEY IDENTITY,
   AuthorID INT ,
   [Name] NVARCHAR(100) NOT NULL,
   [Page Count] INT 
);


CREATE TRIGGER SelectBooksDelete
ON Books
AFTER DELETE
AS
BEGIN
    INSERT INTO DeletedBooks (Name, AuthorID, [Page Count])
    SELECT Name, AuthorID, [Page Count]
    FROM deleted;
END;

DELETE Books WHERE ID = 7

SELECT * FROM DeletedBooks
