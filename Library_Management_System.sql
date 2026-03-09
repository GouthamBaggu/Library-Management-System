-- Library Management System

use library_management_system;

-- 1. Database Setup
DROP TABLE IF EXISTS branch; 

CREATE TABLE branch(
branch_id VARCHAR(10) PRIMARY KEY,	
manager_id	VARCHAR(10) ,
branch_address	VARCHAR(50),
contact_no VARCHAR(10)
);

DROP TABLE IF EXISTS employees;

CREATE TABLE employees(
emp_id	VARCHAR(10) PRIMARY KEY,
emp_name VARCHAR(60),
position VARCHAR(20),
salary	INT,
branch_id VARCHAR(10) -- FK
);

DROP TABLE IF EXISTS books;

CREATE TABLE books(
isbn VARCHAR(20) PRIMARY KEY,
book_title	VARCHAR(75),
category VARCHAR(20),
rental_price FLOAT,
status	VARCHAR(5),
author VARCHAR(25),
publisher VARCHAR(55)
);

DROP TABLE IF EXISTS members;

CREATE TABLE members(
member_id	VARCHAR(10) PRIMARY KEY,
member_name VARCHAR(50),
member_address VARCHAR(50),
reg_date date
);

DROP TABLE IF EXISTS issued_status;

CREATE TABLE issued_status(
issued_id	VARCHAR(15) PRIMARY KEY,
issued_member_id VARCHAR(25), -- FK
issued_book_name VARCHAR(50),
issued_date DATE,
issued_book_isbn VARCHAR(50), -- FK
issued_emp_id VARCHAR(10) -- FK
);

ALTER TABLE issued_status
MODIFY issued_book_name VARCHAR(100);

DROP TABLE IF EXISTS return_status;

CREATE TABLE return_status(
return_id	VARCHAR(20) PRIMARY KEY,
issued_id	VARCHAR(15),  -- FK
return_book_name VARCHAR(50),
return_date	DATE,
return_book_isbn VARCHAR(20)
);

-- 2. CRUD Operations
-- ADDING FOREIGN KEYS TO issued_status
ALTER TABLE issued_status
ADD CONSTRAINT fk_members
FOREIGN KEY(issued_member_id)
REFERENCES members(member_id);

ALTER TABLE issued_status
ADD CONSTRAINT fk_books
FOREIGN KEY(issued_book_isbn)
REFERENCES books(isbn);

ALTER TABLE issued_status
ADD CONSTRAINT fk_employees
FOREIGN KEY(issued_emp_id)
REFERENCES employees(emp_id);

-- ADDING FOREIGN KEYS TO employees
ALTER TABLE employees
ADD CONSTRAINT fk_branch
FOREIGN KEY(branch_id)
REFERENCES branch(branch_id);

-- ADDING FOREIGN KEYS TO return_status
ALTER TABLE return_status
ADD CONSTRAINT fk_return
FOREIGN KEY(issued_id)
REFERENCES issued_status(issued_id);


-- INSERTING DATA INTO TABLES INSERT QUERIES

-- CHECKING THE STRUCTURE OF THE TABLES

-- 1. BOOKS TABLE
SELECT * FROM books
LIMIT 10;

-- 2. BRANCH TABLE
SELECT * FROM branch
LIMIT 10;

-- 3. EMPLOYEES TABLE
SELECT * FROM employees
LIMIT 10;

-- 4. ISSUED STATUS TABLE
SELECT * FROM issued_status
LIMIT 10;

-- 5. MEMBERS TABLE
SELECT * FROM members
LIMIT 10;

-- 6. RETURN STATUS TABLE
SELECT * FROM return_status
LIMIT 10;

-- Project Tasks

-- Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 
-- 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title,category,rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 
6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.'
);

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address = '69 Main Street'
WHERE
member_id = 'C101';

SELECT * FROM members
WHERE member_id = 'C101';

-- Task 3: Delete a Record from the Issued Status Table  
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee 
-- Objective: Select all books issued by the employee with emp_id = 'E101'. 
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book 
-- Objective: Use GROUP BY to find members who have issued more than one book.
SELECT issued_emp_id,
COUNT(*) AS total_issued
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

-- 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables: 
-- Used CTAS to generate new tables based on query results - each book and total book_issued_cnt
CREATE TABLE books_count
AS
SELECT 
	b.isbn,
    b.book_title,
    COUNT(i.issued_id) AS number_of_issued
FROM books AS b
JOIN 
issued_status AS i
ON b.isbn = i.issued_book_isbn
GROUP BY b.isbn, b.book_title;

-- 4. Data Analysis & Findings
-- Task 7. Retrieve All Books in a Specific Category:
SELECT *
FROM books
WHERE category = 'Children';

-- Task 8: Find Total Rental Income by Category:
SELECT 
category,
COUNT(*),
SUM(rental_price)
FROM books
GROUP BY 1
ORDER BY 2 DESC;

-- Task 9: List Members Who Registered in the Last 700 Days:
SELECT *
FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL 700 day ;

-- List Employees with Their Branch Manager's Name and their branch details:
SELECT 
	emp.emp_id,
	emp.emp_name,
	emp.position,
	emp.salary,
	br.*,
	emp2.emp_name AS manager_name
FROM employees AS emp
JOIN 
branch AS br
ON emp.branch_id = br.branch_id
JOIN 
employees AS emp2
ON emp2.emp_id = br.manager_id;

-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:
CREATE TABLE expensive_books
AS
SELECT *
FROM books
WHERE rental_price > 6.0;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM issued_status AS ist
LEFT JOIN
return_status AS re
ON ist.issued_id = re.issued_id
WHERE return_date IS NULL;

/* 
Task 13. Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). 
Display the member's_id, member's name, book title, issue date, and days overdue.
*/

SELECT 
	ist.issued_member_id,
    mem.member_name,
    bk.book_title,
    ist.issued_date,
    CURRENT_DATE() - ist.issued_date AS Over_Due_By
FROM issued_status AS ist
JOIN
members AS mem
ON ist.issued_member_id = mem.member_id
JOIN 
books AS bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date IS NULL
AND
(CURRENT_DATE() - ist.issued_date) > 30
ORDER BY ist.issued_member_id;

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned
(based on entries in the return_status table).
*/

SELECT * FROM books
WHERE isbn = '978-0-451-52994-2';


UPDATE books
SET status = 'no'
WHERE isbn = '978-0-451-52994-2';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-451-52994-2';

SELECT * FROM return_status
WHERE issued_id = 'IS130';  -- There is no return status for book "978-0-451-52994-2" we need to add it

INSERT INTO return_status(return_id, issued_id,return_date,book_quality)
VALUES
('RS125','IS130', CURRENT_DATE(),'GOOD');

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-451-52994-2';

-- This is the manual process that we have to do for every returned book
-- But there is a way we can do it automatically and that way is using PROCEDURES
DELIMITER //
CREATE PROCEDURE add_return_records(p_return_id VARCHAR(50),p_issued_id VARCHAR(50), p_book_quality VARCHAR(10))

BEGIN
	DECLARE
	v_isbn VARCHAR(50);
    DECLARE
    v_book_title VARCHAR(100);
    
	-- Inserting into return status with user given data.
	INSERT INTO return_status(return_id, issued_id,return_date,book_quality)
	VALUES
	(p_return_id,p_issued_id, CURRENT_DATE(),p_book_quality);
    SELECT 
		issued_book_isbn,
        issued_book_name
        INTO 
        v_isbn,
        v_book_title
    FROM issued_status
    WHERE issued_id = p_issued_id
    LIMIT 1;
    
    UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;
    
    SELECT CONCAT('Thanks for returning the book : %',v_book_title) AS MESSAGE_FROM_ADMIN;
END; //
DELIMITER ;



SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_id = 'IS135';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS140', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS150', 'IS140', 'Good');

-- Task 15: Branch Performance Report
-- Create a query that generates a performance report for each branch, showing the number of books issued,
-- the number of books returned, and the total revenue generated from book rentals.
CREATE TABLE branch_report
AS
SELECT 
br.branch_id,
br.manager_id,
COUNT(ist.issued_id) AS Number_book_issued,
COUNT(rs.return_id) AS Total_book_returned,
SUM(bk.rental_price) AS Total_Revenue
FROM issued_status AS ist
JOIN 
employees AS em
ON ist.issued_emp_id = em.emp_id
JOIN branch AS br
ON br.branch_id = em.branch_id
JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
JOIN books AS bk
ON ist.issued_book_isbn = bk.isbn
GROUP BY br.branch_id,br.branch_id
ORDER BY Total_Revenue desc;

SELECT * FROM branch_report;

-- Task 16: CTAS: Create a Table of Active Members
-- Use the CREATE TABLE AS (CTAS) statement to create a new table 
-- active_members containing members who have issued at least one book in the last 2 years.
CREATE 	TABLE active_members
AS
SELECT * FROM members
WHERE member_id IN (
SELECT DISTINCT issued_member_id
FROM issued_status
WHERE issued_date >= CURRENT_DATE - INTERVAL 6 MONTH
);
SELECT * FROM active_members;

-- Task 17: Find Employees with the Most Book Issues Processed
-- Write a query to find the top 3 employees who have processed the most book issues. 
-- Display the employee name, number of books processed, and their branch.
SELECT 
emp.emp_name,
b.*,
COUNT(ist.issued_id) AS no_of_books_issued
FROM
issued_status AS ist
JOIN 
employees AS emp
ON ist.issued_emp_id = emp.emp_id
JOIN branch AS b
ON b.branch_id = emp.branch_id
GROUP BY 1,2
ORDER BY no_of_books_issued DESC;

-- Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. 
-- Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
-- The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
-- The procedure should first check if the book is available (status = 'yes'). If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
DELIMITER //

CREATE PROCEDURE issued_book(
    IN p_issued_id VARCHAR(10),
    IN p_issued_member_id VARCHAR(30),
    IN p_issued_book_isbn VARCHAR(50),
    IN p_issued_emp_id VARCHAR(10)
)

BEGIN

    DECLARE v_status VARCHAR(10);

    -- Check book status
    SELECT status
    INTO v_status
    FROM books
    WHERE isbn = p_issued_book_isbn
    LIMIT 1;

    -- If book is available
    IF v_status = 'yes' THEN
    
        INSERT INTO issued_status
        (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES
        (p_issued_id, p_issued_member_id, CURRENT_DATE(), p_issued_book_isbn, p_issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = p_issued_book_isbn;

        SELECT CONCAT('Book issued successfully: ', p_issued_book_isbn);

    ELSE
    
        SELECT CONCAT('Sorry, book is not available: ', p_issued_book_isbn);

    END IF;

END //

DELIMITER ;

-- Testing the procedure

-- 978-0-06-025492-6 --> YES
-- 978-0-375-41398-8 --> NO

SELECT * FROM books;
SELECT * FROM issued_status;

CALL issued_book('IS155','C108','978-0-06-025492-6','E104');

CALL issued_book('IS156','C108',' 978-0-375-41398-8','E105');