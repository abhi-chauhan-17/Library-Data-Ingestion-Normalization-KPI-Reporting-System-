CREATE DATABASE LibraryRaw

USE LibraryRaw

CREATE TABLE LoanTransactionalData (
    LibraryID VARCHAR(10),
    LoanID VARCHAR(20) PRIMARY KEY,
    StudentID VARCHAR(20),
    BookID VARCHAR(20),
    LoanDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    PenaltyPaidDate DATE,
    PaymentMethod VARCHAR(20),
    Amount DECIMAL(10, 2)
);

BULK INSERT LoanTransactionalData
FROM 'D:\LibrarySqlProj\LoanTransactionalData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT * FROM LoanTransactionalData



CREATE TABLE UserTransactionalData (
    UserID VARCHAR(10) PRIMARY KEY,
    InstitutionName VARCHAR(100),
    InstitutionAddress VARCHAR(100),
    InstitutionEmail VARCHAR(100),
    InstitutionPhoneNo VARCHAR(15),
    UserProfession VARCHAR(50),
    UserGovtIdType VARCHAR(50),
    UserIdNumber VARCHAR(20),
    UserAddress VARCHAR(100),
    MembershipStatus VARCHAR(10)
)
BULK INSERT UserTransactionalData
FROM 'D:\LibrarySqlProj\UserTransactionalData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT * FROM UserTransactionalData

CREATE TABLE OrderTransactionalData (
    LibraryID VARCHAR(10),
    OrderID VARCHAR(10) PRIMARY KEY,
    VendorID VARCHAR(10),
    BookID VARCHAR(10),
    Quantity INT,
    TotalPrice DECIMAL(10, 2),
    BookTitle VARCHAR(100),
    BookGenre VARCHAR(50),
    AuthorName VARCHAR(100),
    ActionDate DATE,
    ActionType VARCHAR(20)
)

BULK INSERT OrderTransactionalData
FROM 'D:\LibrarySqlProj\OrderTransactionalData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);

Select * from OrderTransactionalData

CREATE TABLE VendorData (
    VendorID VARCHAR(10) PRIMARY KEY,
    VendorName VARCHAR(100),
    Address VARCHAR(100),
    PhoneNo VARCHAR(15)
)

BULK INSERT VendorData
FROM 'D:\LibrarySqlProj\VendorData.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


Select * from LoanTransactionalData	--Loan Table,Payment Table

Select LoanId,StudentID,BookID,LoanDate,DueDate,ReturnDate from LoanTransactionalData
Select  LoanId,PenaltyPaidDate,ISNULL(PaymentMethod,'No Penalty') as PaymentMethod,Amount from LoanTransactionalData where PenaltyPaidDate IS NOT NULL


CREATE TABLE Loan (
    LoanID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    StudentID VARCHAR(10),
    BookID VARCHAR(10),
    LoanDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (LibraryID) REFERENCES Library(LibraryID),
    FOREIGN KEY (StudentID) REFERENCES User(UserID),
    FOREIGN KEY (BookID) REFERENCES Book(BookID)
);

CREATE TABLE Payment (
	PaymentID int identity(100,1),
    LoanID VARCHAR(10),
    PenaltyPaidDate DATE,
    PaymentMethod VARCHAR(10),
    Amount DECIMAL(10,2),
    FOREIGN KEY (LoanID) REFERENCES Loan(LoanID)
);


Select UserID,InstitutionName,UserProfession,UserGovtIdType,UserIdNumber,UserAddress,MembershipStatus from UserTransactionalData	--User Table 


Select InstitutionAddress,InstitutionName,InstitutionPhoneNo,InstitutionEmail from UserTransactionalData -- Institute Table




Select * from UserTransactionalData

Select OrderID,LibraryID,VendorID,BookID,Quantity,ActionDate,ActionType from OrderTransactionalData

Select BookTitle,BookGenre,AuthorName from OrderTransactionalData Group by BookTitle,BookGenre,AuthorName

Select BookTitle,LibraryID,BookID,VendorID,BookGenre from OrderTransactionalData Order by LibraryID,BookId,VendorID,BookGenre,BookTitle

Select * from OrderTransactionalData

Select Distinct LibraryID from OrderTransactionalData  ORDER BY CAST(SUBSTRING(LibraryID,2,len(LibraryID)) as int)

Select * from VendorData  



CREATE TABLE Libraries (
    LibraryID VARCHAR(10) PRIMARY KEY
);
Select * from Libraries

CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100)
);
INSERT INTO Authors(Name)
SELECT Distinct AuthorName
From OrderTransactionalData








Select * from Loan

 CREATE TABLE Loan (
    LoanID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    StudentID VARCHAR(10),
	BookKey int,
    LoanDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (LibraryID) REFERENCES Libraries(LibraryID),
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
	FOREIGN KEY (BookKey) REFERENCES Books(BookKey)
);
Drop table Loan
WITH BookMatch AS (
    SELECT
        l.LoanID,
        l.LibraryID,
        l.StudentID,
        l.BookID,
        l.LoanDate,
        l.DueDate,
        l.ReturnDate,
        b.BookKey,
        ROW_NUMBER() OVER (
            PARTITION BY l.LoanID
            ORDER BY b.BookKey
        ) AS rn
    FROM LoanTransactionalData l
    LEFT JOIN Books b
        ON l.BookID = b.BookID
)
INSERT INTO Loan (
    LoanID, LibraryID, StudentID, BookKey, LoanDate, DueDate, ReturnDate
)
SELECT
    LoanID,
    LibraryID,
    StudentID,
    BookKey,
    LoanDate,
    DueDate,
    ReturnDate
FROM BookMatch
WHERE rn = 1 


Select * from loan

Select * from LoanTransactionalData
Select * from Books


Select * from Loans
Select * from Books

Select * from Orders



Select * from Loans
Select * from OrderTransactionalData
 Select * from LoanTransactionalData

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    LoanID VARCHAR(10),
    PaymentMethod VARCHAR(50),
    PenaltyPaidDate DATE,
    Amount DECIMAL(10,2),
    FOREIGN KEY (LoanID) REFERENCES Loan2(LoanID),
);
Drop table Payments
Alter table Payments
Add CONSTRAINT FK_LoanID_Payments FOREIGN KEY(LoanID) 
References Loan2(LoanID)
INSERT INTO Payments
(LoanID,PaymentMethod,PenaltyPaidDate,Amount)
SELECT 
	l.LoanID,
	l.PaymentMethod,
	l.PenaltyPaidDate,
	l.Amount
	FROM LoanTransactionalData l
	Where Amount<>0
Select * from Payments



CREATE TABLE Books (
    BookKey INT IDENTITY(1,1) PRIMARY KEY,  
    BookID VARCHAR(20),
    LibraryID VARCHAR(10),
    VendorID VARCHAR(10),
    Title VARCHAR(100),
    Genre VARCHAR(50),
    UNIQUE (BookID, LibraryID, VendorID, Genre),
	FOREIGN KEY (LibraryID) REFERENCES Libraries(LibraryID),
    
);
ALTER TABLE Books
ADD CONSTRAINT FK_Books_Vendor
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID);

INSERT INTO Books(BookID, LibraryID, VendorID, Title, Genre)
SELECT DISTINCT
    BookID,
    LibraryID,
    VendorID,
    BookTitle,
    BookGenre
FROM OrderTransactionalData
WHERE BookID IS NOT NULL
  AND LibraryID IS NOT NULL
  AND VendorID IS NOT NULL
  AND BookGenre IS NOT NULL;

Select * from Books

INSERT INTO Libraries(LibraryID)
SELECT distinct LibraryID from OrderTransactionalData


CREATE TABLE Orders (
    OrderID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    VendorID VARCHAR(10),
    BookKey int,
	BookID VARCHAR(10),
    Quantity INT,
    TotalPrice DECIMAL(10,2),
    ActionDate DATE,
    ActionType VARCHAR(50),
    FOREIGN KEY (LibraryID) REFERENCES Libraries(LibraryID),
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID),
    FOREIGN KEY (BookKey) REFERENCES Books(BookKey)
);
DROP TABLE Orders

INSERT INTO Orders (OrderID,LibraryID,VendorID,BookKey,BookID,Quantity,TotalPrice,ActionDate,ActionType)
SELECT DISTINCT
	o.OrderID,
	o.LibraryID,
	o.VendorID,
	b.BookKey,
	b.BookID,
	o.Quantity,
	o.TotalPrice,
	o.ActionDate,
	o.ActionType
	From OrderTransactionalData o
	JOIN Books b
	 ON b.BookID = o.BookID
 AND b.LibraryID = o.LibraryID
 AND b.VendorID = o.VendorID
 AND b.Genre = o.BookGenre;

Select * from Orders

Select * from Books





CREATE TABLE Institutions (
    InstitutionID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(200),
    Email VARCHAR(100),
    PhoneNo VARCHAR(15)
);

INSERT INTO Institutions(Name,Address,Email,PhoneNo)
SELECT DISTINCT 
	InstitutionName,
	InstitutionAddress,
	InstitutionEmail,
	InstitutionPhoneNo
	from UserTransactionalData

Select * from Institutions


CREATE TABLE Users (
    UserID VARCHAR(10) PRIMARY KEY,
    InstitutionID INT,
    Profession VARCHAR(50),
    GovtIdType VARCHAR(50),
    GovtIdNumber VARCHAR(50),
    Address VARCHAR(200),
    MembershipStatus VARCHAR(50),
    FOREIGN KEY (InstitutionID) REFERENCES Institutions(InstitutionID)
);


INSERT INTO Users(UserID,InstitutionID,Profession,GovtIdType,GovtIdNumber,Address,MembershipStatus)
SELECT DISTINCT
	u.UserID,
	i.InstitutionID,
	u.UserProfession,
	u.UserGovtIdType,
	u.UserIdNumber,
	u.UserAddress,
	u.MembershipStatus
	From UserTransactionalData u
	JOIN Institutions i
	ON u.InstitutionEmail= i.Email and u.InstitutionAddress = i.Address

Select * from Users

Select * from Authors
Select * from BookAuthors
Select * from Loan
Select studentid from Payments group by studentid





CREATE TABLE Book1 (
    BookKey   INT IDENTITY(1,1) PRIMARY KEY,
    BookID    VARCHAR(20),
    Title     VARCHAR(100),
    AuthorID  INT,
    LibraryID VARCHAR(10),
    Genre     VARCHAR(50),
    VendorID  VARCHAR(10),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
	FOREIGN KEY (LibraryID) REFERENCES Libraries(LibraryID),
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID)
);


INSERT INTO Book1 (BookID, Title, AuthorID, LibraryID, Genre, VendorID)
SELECT
    s.BookID,
    s.BookTitle,
    a.AuthorID,
    s.LibraryID,
    s.BookGenre,
    s.VendorID
FROM OrderTransactionalData s
JOIN Authors a ON a.Name = s.AuthorName;

Select * from Book1

Select * from OrderTransactionalData

Select * from Users

Select * from Orders

CREATE TABLE Reservations (
    ReservationID   INT IDENTITY(1,1) PRIMARY KEY,
    UserID          VARCHAR(20),         
    BookKey         INT,                  
    ReservationDate DATE DEFAULT GETDATE(),
    Status          VARCHAR(20) DEFAULT 'Pending',  
    ExpiryDate      DATE,                 
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (BookKey) REFERENCES Books(BookKey)
);


Drop Table Reservations
CREATE PROCEDURE ReserveBook
@UserID VARCHAR(10),
@BookKey int
AS
Insert into Reservations(UserID,BookKey) values (@UserID,@BookKey)

ReserveBook 'U1023', 89

Select * from Reservations

Select * from Users

Select b.BookID,count(b.bookid),ActionDate,b.ActionType from OrderTransactionalData b
group by b.BookID,b.ActionType,ActionDate
having count(ActionType)=1

Select Count(distinct bookid) from OrderTransactionalData


SELECT BookID
FROM OrderTransactionalData
GROUP BY BookID
HAVING COUNT(ActionType) = 1;

SELECT BookID,Count(actiontype)
FROM OrderTransactionalData
GROUP BY BookID
HAVING COUNT(ActionType) <> 1;

SELECT BookID
FROM OrderTransactionalData
GROUP BY BookID, ActionType
HAVING COUNT(*) > 1;


Select * from OrderTransactionalData
order by bookid


WITH ActionRanked AS (
    SELECT
        BookID,
        ActionType,
        ActionDate,
        RANK() OVER (
            PARTITION BY BookID
            ORDER BY 
                CASE ActionType
                    WHEN 'Ordered' THEN 1
                    WHEN 'Returned' THEN 2
                    WHEN 'Cancelled' THEN 3
                    ELSE 4
                END,
                ActionDate DESC
        ) AS rn
    FROM OrderTransactionalData
) 
SELECT BookID, ActionType
FROM (
    SELECT
        BookID,
        ActionType,
        RANK() OVER (
            PARTITION BY BookID
            ORDER BY 
                CASE ActionType
                    WHEN 'Ordered' THEN 1
                    WHEN 'Returned' THEN 2
                    WHEN 'Cancelled' THEN 3
                    ELSE 4
                END,
                ActionDate DESC
        ) AS rn
    FROM OrderTransactionalData
) AS Ranked
WHERE rn = 1;



CREATE TABLE Book2 (
    BookID    VARCHAR(20) PRIMARY KEY,
    Title     VARCHAR(100),
    AuthorID  INT,
    LibraryID VARCHAR(10),
    Genre     VARCHAR(50),
    VendorID  VARCHAR(10),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID)
);

INSERT INTO Book2 (BookID, Title, AuthorID, LibraryID, Genre, VendorID)
SELECT
    s.BookID,
    s.BookTitle,
    a.AuthorID,
    s.LibraryID,
    s.BookGenre,
    s.VendorID
FROM vUQB s
JOIN Authors a ON a.Name = s.AuthorName


Select * from Book2

Select * from vUQB


Drop View vUQB
CREATE VIEW vUQB
AS
(
SELECT *
FROM (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY BookID
            ORDER BY 
                CASE ActionType
                    WHEN 'Ordered' THEN 1
                    WHEN 'Returned' THEN 2
                    WHEN 'Cancelled' THEN 3
                    ELSE 4
                END,
                ActionDate DESC
        ) AS rn
    FROM OrderTransactionalData
) AS Ranked
WHERE rn = 1
)
Select * from OrderTransactionalData


CREATE TABLE Orders2 (
    OrderID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    VendorID VARCHAR(10),
	BookID VARCHAR(20),
    Quantity INT,
    TotalPrice DECIMAL(10,2),
    ActionDate DATE,
    ActionType VARCHAR(50),
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID),
    FOREIGN KEY (BookID) REFERENCES Book2(BookID)
);

INSERT INTO Orders2 (OrderID,LibraryID,VendorID,BookID,Quantity,TotalPrice,ActionDate,ActionType)
SELECT DISTINCT
	o.OrderID,
	o.LibraryID,
	o.VendorID,
	b.BookID,
	o.Quantity,
	o.TotalPrice,
	o.ActionDate,
	o.ActionType
	From OrderTransactionalData o
	JOIN Book2 b
	 ON b.BookID = o.BookID

Select * from Orders2

Select * from Users

 CREATE TABLE Loan2 (
    LoanID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    StudentID VARCHAR(10),
	BookID	VARCHAR(20),
    LoanDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
	FOREIGN KEY (BookID) REFERENCES Book2(BookID)
);

INSERT INTO Loan2(
    LoanID, LibraryID, StudentID, BookID, LoanDate, DueDate, ReturnDate)
SELECT
    l.LoanID,
    l.LibraryID,
    l.StudentID,
    b.BookID,
    l.LoanDate,
    l.DueDate,
    l.ReturnDate
FROM LoanTransactionalData l
JOIN BOOK2 b
ON l.BookID = b.BookID

Select * from Loan2
Select * from Loan

Select * from Institutions
Select * from VendorData

Select * from Payments