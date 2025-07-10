CREATE DATABASE LibraryClean

USE LibraryClean

CREATE TABLE Authors (
    AuthorID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100)
)

CREATE TABLE VendorData (
    VendorID VARCHAR(10) PRIMARY KEY,
    VendorName VARCHAR(100),
    Address VARCHAR(100),
    PhoneNo VARCHAR(15)
)

CREATE TABLE Institutions (
    InstitutionID INT IDENTITY(1,1) PRIMARY KEY,
    Name VARCHAR(100),
    Address VARCHAR(200),
    Email VARCHAR(100),
    PhoneNo VARCHAR(15)
)

CREATE TABLE Users (
    UserID VARCHAR(10) PRIMARY KEY,
    InstitutionID INT,
    Profession VARCHAR(50),
    GovtIdType VARCHAR(50),
    GovtIdNumber VARCHAR(50),
    Address VARCHAR(200),
    MembershipStatus VARCHAR(50),
    FOREIGN KEY (InstitutionID) REFERENCES Institutions(InstitutionID)
)

CREATE TABLE Books (
    BookID    VARCHAR(20) PRIMARY KEY,
    Title     VARCHAR(100),
    AuthorID  INT,
    LibraryID VARCHAR(10),
    Genre     VARCHAR(50),
    VendorID  VARCHAR(10),
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID),
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID)
)

CREATE TABLE Orders(
    OrderID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    VendorID VARCHAR(10),
	BookID VARCHAR(20),
    Quantity INT,
    TotalPrice DECIMAL(10,2),
    ActionDate DATE,
    ActionType VARCHAR(50),
    FOREIGN KEY (VendorID) REFERENCES VendorData(VendorID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
)

CREATE TABLE Loans (
    LoanID VARCHAR(10) PRIMARY KEY,
    LibraryID VARCHAR(10),
    StudentID VARCHAR(10),
	BookID	VARCHAR(20),
    LoanDate DATE,
    DueDate DATE,
    ReturnDate DATE,
    FOREIGN KEY (StudentID) REFERENCES Users(UserID),
	FOREIGN KEY (BookID) REFERENCES Books(BookID)
)

CREATE TABLE Payments (
    PaymentID INT IDENTITY(1,1) PRIMARY KEY,
    LoanID VARCHAR(10),
    PaymentMethod VARCHAR(50),
    PenaltyPaidDate DATE,
    Amount DECIMAL(10,2),
    FOREIGN KEY (LoanID) REFERENCES Loans(LoanID),
)
Drop table Institutions
Drop table Users
Drop table Books
Drop table Orders
Drop table Payments
Drop table Authors
Drop table Loans


Select * from Users
Select * from Institutions
Select * from VendorData
Select * from Books
Select * from Authors
Select * from Loans
Select * from Orders
Select * from Payments

ALTER PROCEDURE spTransferLibraryData
AS
BEGIN
    SET NOCOUNT ON;

		INSERT INTO LibraryClean.dbo.Institutions( Name, Address,Email ,PhoneNo)
        SELECT Name, Address,Email ,PhoneNo FROM LibraryRaw.dbo.Institutions;

        INSERT INTO LibraryClean.dbo.Users
        SELECT * FROM LibraryRaw.dbo.Users;



        INSERT INTO LibraryClean.dbo.VendorData
        SELECT * FROM LibraryRaw.dbo.VendorData;


		INSERT INTO LibraryClean.dbo.Authors(Name)
        SELECT [Name] FROM LibraryRaw.dbo.Authors;


        INSERT INTO LibraryClean.dbo.Books(BookID,AuthorID,LibraryID, VendorID, Title , Genre)
        SELECT BookID,AuthorID,LibraryID, VendorID, Title , Genre FROM LibraryRaw.dbo.Book2;


		INSERT INTO LibraryClean.dbo.Orders
        SELECT * FROM LibraryRaw.dbo.Orders2;


        INSERT INTO LibraryClean.dbo.Loans
        SELECT * FROM LibraryRaw.dbo.Loan2;


		INSERT INTO LibraryClean.dbo.Payments(LoanID ,PaymentMethod, PenaltyPaidDate, Amount)
        SELECT LoanID ,PaymentMethod, PenaltyPaidDate, Amount FROM LibraryRaw.dbo.Payments;
    
END



EXECUTE spTransferLibraryData



CREATE VIEW OverdueBooks AS
SELECT 
    L.LoanID, L.StudentID, L.BookID, L.DueDate, L.ReturnDate,
    DATEDIFF(DAY, L.DueDate, GETDATE()) AS OverdueDays
	FROM Loans L
	WHERE L.ReturnDate IS NULL AND L.DueDate < GETDATE();

Select * from OverdueBooks

CREATE VIEW CalculatePenalty
AS
(
SELECT 
    LoanID,
    DATEDIFF(DAY, DueDate, ISNULL(ReturnDate, GETDATE())) AS OverdueDays,
    CASE 
        WHEN DATEDIFF(DAY, DueDate, ISNULL(ReturnDate, GETDATE())) > 0 
        THEN DATEDIFF(DAY, DueDate, ISNULL(ReturnDate, GETDATE())) * 10
        ELSE 0 
    END AS PenaltyAmount
FROM 
    Loans
WHERE 
    DueDate < ISNULL(ReturnDate, GETDATE())
)

Select * from CalculatePenalty



ALTER PROCEDURE UpdateReservation
AS
BEGIN
	UPDATE Reservations 
	SET Status = 'Expired'
	WHERE Status = 'Pending' and ExpiryDate <GetDate()
END


ALTER PROCEDURE BorrowBook
    @LibraryID VARCHAR(10),
    @StudentID VARCHAR(10),
    @BookID VARCHAR(20)
AS
BEGIN
	Declare @ReturnDate DATE
	Select @ReturnDate = MAX(ReturnDate) from Loans where BookID = @BookID and LibraryID = @LibraryID
	
	IF EXISTS (
    SELECT 1 FROM Loans
    WHERE BookID = @BookID AND ReturnDate IS NULL
	)
	BEGIN
		Insert into Reservations(UserID,BookID,LibraryID)  values (@StudentID,@BookID,@LibraryID)
		RAISERROR('This book is currently issued to someone else.', 16, 1);
		RETURN;
	END
	ELSE IF EXISTS (
		SELECT 1
		FROM Reservations
	    WHERE BookID = @BookID
		AND Status = 'Pending'
		AND ExpiryDate >= GETDATE()
		AND UserID <> @StudentID
	)
	BEGIN
		RAISERROR('This book is reserved by another user.', 16, 1)
	END
	ELSE
	BEGIN
	IF(GETDATE()>@ReturnDate)
	BEGIN
		INSERT INTO Loans (LoanID, LibraryID, StudentID, BookID, LoanDate, DueDate)
	    VALUES (CONCAT('LN',CAST(SUBSTRING((Select MAX(LoanID) from Loans),3,6) as int)+1), @LibraryID, @StudentID, @BookID, GETDATE(),(DATEADD(DAY, 10, GETDATE())))
		
		UPDATE Reservations
		SET Status = 'Fulfilled'
		WHERE BookID = @BookID
		AND UserID = @StudentID
		AND Status = 'Pending'
		AND LibraryID = @LibraryID
	END
	ELSE IF (GETDATE()<@ReturnDate)
	BEGIN
		IF EXISTS (
		SELECT 1
		FROM Reservations
	    WHERE BookID = @BookID
		AND Status = 'Pending'
		AND ExpiryDate >= GETDATE()
		AND UserID = @StudentID
	)
	BEGIN
		RAISERROR('This book is already reserved by this user.', 16, 1)
	END
	ELSE
			BEGIN
			Insert into Reservations(UserID,BookID,LibraryID)  values (@StudentID,@BookID,@LibraryID)
			END
	END
	ELSE
		BEGIN
			print 'Enter Correct Credentials'
		END
	END

END

CREATE TABLE Reservations (
    ReservationID   INT IDENTITY(1,1) PRIMARY KEY,
    UserID          VARCHAR(10),         
    BookID          VARCHAR(20),
	LibraryID		Varchar(20),
    ReservationDate DATE DEFAULT GETDATE(),
    Status          VARCHAR(20) DEFAULT 'Pending',  
    ExpiryDate      DATE DEFAULT GETDATE() +3,                 
    FOREIGN KEY (UserID) REFERENCES Users(UserID),
    FOREIGN KEY (BookID) REFERENCES Books(BookID)
);


BorrowBook 'L10','U1010','B228'

Drop table Reservations
Select * from Books

Select * from Loans Order by ReturnDAte DESC
Select  * from Loans
Select * from Reservations


CREATE VIEW BookPopularity AS
SELECT 
    Top 5 B.Title,B.Genre,
    COUNT(L.LoanID) AS BorrowedCount
	FROM Books B
	JOIN Loans L ON B.BookID = L.BookID
	GROUP BY B.Title,B.Genre
	ORDER BY BorrowedCount DESC;

Select * from BookPopularity


ALTER PROCEDURE ReturnBook
    @LoanID VARCHAR(10),
	@PayMethod nvarchar(10)
AS
BEGIN
    DECLARE @DueDate DATE, @PenaltyAmount DECIMAL(10,2)

    SELECT @DueDate = DueDate FROM Loans WHERE LoanID = @LoanID;

    UPDATE Loans SET ReturnDate = GETDATE() WHERE LoanID = @LoanID;

    IF (GETDATE() > @DueDate)
    BEGIN
        SET @PenaltyAmount = DATEDIFF(DAY, @DueDate, GETDATE()) * 10;

        INSERT INTO Payments (LoanID,  PaymentMethod, PenaltyPaidDate, Amount)
        VALUES (@LoanID,@PayMethod, GETDATE(), @PenaltyAmount);
    END
END

ReturnBook 'LN2010','Online'

Select * from Payments
Select * from Loans




CREATE VIEW UserActivitySummary AS
SELECT U.UserID,
    COUNT(DISTINCT L.LoanID) AS TotalLoans,
    ISNULL(SUM(P.Amount),0) AS TotalPenaltyPaid
	FROM Users U
	LEFT JOIN Loans L ON U.UserID = L.StudentID
	LEFT JOIN Payments P ON L.LoanID = P.LoanID
	GROUP BY U.UserID

Select * from UserActivitySummary


CREATE View PenlatyPaidReport
AS
(
SELECT 
    MONTH(PenaltyPaidDate) AS Month,
    SUM(Amount) AS TotalCollected
FROM 
    Payments
GROUP BY MONTH(PenaltyPaidDate)
)

Select * from PenlatyPaidReport

