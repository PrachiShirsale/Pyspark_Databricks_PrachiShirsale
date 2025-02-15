USE AdventureWorks2022
--************************************************ DDL***************************************************** 

/*1 Create a customer table having following column with suitable data type
Cust_id  (automatically incremented primary key)
Customer name (only characters must be there)
Aadhar card (unique per customer)
Mobile number (unique per customer)
Date of birth (check if the customer is having age more than15)
Address
Address type code (B- business, H- HOME, O-office and should not accept any other)
State code ( MH � Maharashtra, KA for Karnataka)*/

CREATE TABLE customer(
   CustId INT IDENTITY(1,1) PRIMARY KEY ,
   CName VARCHAR(40) NOT NULL CHECK (CName NOT LIKE '%[^a-zA-Z]%'),
   CAdhar VARCHAR(10) UNIQUE NOT NULL CHECK (LEN(CAdhar) = 12),
   CMob VARCHAR(10) UNIQUE NOT NULL CHECK (CMob LIKE '[6-9][0-9]{9}'), 
   CDOB DATETIME NOT NULL CHECK (DATEDIFF(YEAR , CDOB , GETDATE()) > 15),
   CAdd VARCHAR(100) NOT NULL ,
   AddTypeCode CHAR(1) NOT NULL CHECK (AddTypeCode IN('B' , 'O' , 'H')),
   StateCode CHAR(2) NOT NULL CHECK (StateCode IN('Mh' , 'KA'))
);

SELECT * FROM customer 

-- 2 
/*Create another table for Address type which is having
Address type code must accept only (B,H,O)
Address type  having the information as  (B- business, H- HOME, O-office) */

CREATE TABLE AddType(
  AddTypCode CHAR(1) PRIMARY KEY NOT NULL CHECK((AddTypCode IN('B' , 'O' , 'H'))),
  AddTypDesp VARCHAR(50) NOT NULL 
);

SELECT * FROM AddType
INSERT INTO AddType VALUES('B' , 'Business') , ('O' , 'Office') , ('H'  , 'Home')

-- 3 
/*Create table state_info having columns as  
State_id  primary unique
State name 
Country_code char(2)*/

CREATE TABLE stateInfo(
 StateId INT PRIMARY KEY IDENTITY(1,1),
 StateName VARCHAR(50) NOT NULL,
 CountryCode CHAR(2) NOT NULL
);
SELECT * FROM stateInfo

--4 
/*   Alter tables to link all tables based on suitable columns and foreign keys.  */
ALTER TABLE customer ADD CONSTRAINT Const_AddTypeCode
FOREIGN KEY(AddTypeCode) REFERENCES  AddType(AddTypCode)

ALTER TABLE customer 
ADD StateID INT NOT NULL;

ALTER TABLE customer ADD CONSTRAINT Const_StateID
FOREIGN KEY(StateID) REFERENCES StateInfo(StateId)

-- 5 
/* Change the column name from customer table customer name as c_name */

-- EXEC sp_rename 'customer.Cname' , 'c_name' , 'COLUMN'
-- As the table already exixts, first we need to first drop the constraint and then rename the col and then again add the constraint.

SELECT name 
FROM sys.check_constraints 
WHERE parent_object_id = OBJECT_ID('customer');

ALTER TABLE customer 
DROP CONSTRAINT CK__customer__CName__61BB7BD9;

EXEC sp_rename 'customer.Cname' , 'C_name' , 'COLUMN'

ALTER TABLE customer 
ADD CONSTRAINT CK_Customer_C_Name 
CHECK (C_Name NOT LIKE '%[^a-zA-Z]%');

-- 6. Insert the suitable records into the respective tables

INSERT INTO stateInfo (StateName, CountryCode) 
VALUES 
    ('Maharashtra', 'IN'),
    ('Karnataka', 'IN'),
    ('Gujarat', 'IN'),
    ('Tamil Nadu', 'IN'),
    ('West Bengal', 'IN');

SELECT * FROM stateInfo;

ALTER TABLE customer 
ALTER COLUMN CAdhar VARCHAR(12) NOT NULL;

INSERT INTO customer (C_name, CAdhar, CMob, CDOB, CAdd, AddTypeCode, StateCode, StateID)
VALUES 
    ('Rahul', '123456789012', '9876543210', '1995-05-10', 'Pune, MH', 'B', 'Mh', 1),
    ('Priya', '234567890123', '9123456789', '1998-07-15', 'Bangalore, KA', 'H', 'KA', 2),
    ('Amit', '345678901234', '9786543210', '2000-01-20', 'Surat, GJ', 'O', 'GJ', 3),
    ('Neha', '456789012345', '9234567890', '1997-12-25', 'Chennai, TN', 'B', 'TN', 4),
    ('Arjun', '567890123456', '9345678901', '1996-04-30', 'Kolkata, WB', 'H', 'WB', 5);

SELECT * FROM customer;


--  7. Change the data type of  country_code to varchar(3)
ALTER TABLE stateInfo
ALTER COLUMN CountryCode VARCHAR(3) NOT NULL;

--***************************Based on adventurework solve the following questions**************************

-- 1 . find the average currency rate conversion from USD to Algerian Dinar and Australian Doller  
SELECT cr.FromCurrencyCode, cr.ToCurrencyCode, AVG(AverageRate) as avgRate
FROM Sales.CurrencyRate cr
WHERE cr.FromCurrencyCode = 'USD' and  ToCurrencyCode in ('AUD' , 'DZD')
Group By FromCurrencyCode , ToCurrencyCode

--2.  Find the products having offer on it and display product name , safety Stock Level, Listprice,  and product model id, type of discount,  percentage of discount,  offer start date and offer end date 

SELECT p.ProductID ,
	p.Name,
	p.SafetyStockLevel ,
	p.ListPrice ,
	p.ProductModelID ,
	so.Type ,
	so.DiscountPct,
	so.StartDate,
	so.EndDate 
FROM Production.Product p, 
Sales.SpecialOfferProduct sop,
Sales.SpecialOffer so 
WHERE p.ProductID = sop.ProductID
and so.SpecialOfferID = sop.SpecialOfferID

--3. create  view to display Product name and Product review
SELECT pv.BusinessEntityID,
pv.ProductID,
(SELECT v.Name
FROM Purchasing.Vendor v
WHERE v.BusinessEntityID = pv.BusinessEntityID
) VendorName ,
(SELECT p.Name
FROM Production.Product p 
WHERE p.ProductID = pv.ProductID
) ProductName
FROM Purchasing.ProductVendor pv
WHERE pv.ProductID In 
(SELECT p.ProductID
FROM Production.Product p
WHERE p.Name LIKE '%paint%' OR p.Name LIKE '%Adjustable Race%' OR p.Name LIKE '%Blade%'
)

-- 5. find product details shipped through ZY - EXPRESS 
SELECT *
FROM Production.Product p ,
Sales.SalesOrderHeader soh,
Purchasing.ShipMethod sm,
Sales.SalesOrderDetail sod
WHERE p.ProductID = sod.ProductID
and sod.SalesOrderID = soh.SalesOrderID
and sm.ShipMethodID = soh.ShipMethodID
and sm.Name = 'ZY - EXPRESS'
-- No data 


SELECT p.Name,
p.ProductID,
p.ListPrice,
p.ProductNumber,
sm.Name,
poh.ShipMethodID
FROM Production.Product p ,
Purchasing.PurchaseOrderHeader poh,
Purchasing.ShipMethod sm,
Purchasing.PurchaseOrderDetail pod
WHERE p.ProductID = pod.ProductID
and pod.PurchaseOrderID = poh.PurchaseOrderID
and sm.ShipMethodID = poh.ShipMethodID
and sm.Name = 'ZY - EXPRESS'
GROUP BY  p.Name,
p.ProductID,
p.ListPrice,
p.ProductNumber,
sm.Name,
poh.ShipMethodID

-- 6.  find the tax amt for products where order date and ship date are on the same day 
SELECT p.Name ,
soh.TaxAmt,
soh.OrderDate,
soh.ShipDate,
sod.ProductID
FROM Production.Product p,
Sales.SalesOrderHeader soh,
Sales.SalesOrderDetail sod
WHERE sod.ProductID = p.ProductID
and sod.SalesOrderID = soh.SalesOrderID 
and sod.ProductID IN
(SELECT p.ProductID
WHERE soh.OrderDate = soh.ShipDate)

-- 7.  find the average days required to ship the product based on shipment type. 
SELECT sm.Name ,
	   AVG(DATEDIFF(Day , soh.OrderDate , soh.ShipDate)) AvgShipDays
FROM Purchasing.PurchaseOrderHeader soh,
	 Purchasing.ShipMethod sm
WHERE soh.ShipMethodID = sm.ShipMethodID
GROUP BY sm.Name

-- 8. find the name of employees working in day shift 
SELECT 
edh.BusinessEntityID,
(SELECT s.Name
FROM HumanResources.Shift s
WHERE s.ShiftID = edh.ShiftID) ShiftTime,
(SELECT p.FirstName
FROM Person.Person p 
WHERE p.BusinessEntityID =  edh.BusinessEntityID) PersonName 
FROM HumanResources.EmployeeDepartmentHistory edh
WHERE edh.shiftID In (
SELECT s.ShiftID
FROM HumanResources.Shift s
WHERE s.Name in ('Day')
and EndDate is null)


-- 9. based on product and product cost history find the name , service provider time and average Standardcost   

SELECT pch.ProductID,
(SELECT p.Name
FROM Production.Product p
WHERE p.ProductID = pch.ProductID) ProductName,
AVG(pch.StandardCost) as avgStdCst,
DATEDIFF(hour, pch.StartDate , pch.EndDate ) as datedif
FROM Production.ProductCostHistory pch
GROUP BY pch.StandardCost , pch.ProductID, pch.StartDate , pch.EndDate

-- 10 find products with average cost more than 500 
SELECT pch.ProductID,
	   AVG(pch.StandardCost) AvgCost
FROM Production.Product p, 
Production.ProductCostHistory pch
WHERE p.ProductID = pch.ProductID 
GROUP BY pch.ProductID
HAVING AVG(pch.StandardCost) > 500

-- 11.  find the employee who worked in multiple territory 
SELECT  e.BusinessEntityID,
count(sth.TerritoryID) Territorycnt,
(SELECT p.FirstName
FROM Person.Person p
WHERE p.BusinessEntityID = e.BusinessEntityID)
FROM  Sales.SalesTerritoryHistory sth, HumanResources.Employee e
WHERE e.BusinessEntityID = sth.BusinessEntityID
GROUP BY e.BusinessEntityID
HAVING COUNT(sth.TerritoryID) > 1 

-- 12. find out the Product model name,  product description for culture as Arabic 

-- Production.ProductDescription ---> pdid
-- Production.ProductModelProductDescription ---> productModelID , ProductDescriptionID , CultureID  --> ar 
-- Production.ProductModel --> ProductModelID , Name 

SELECT 
(SELECT pm.Name
FROM Production.ProductModel pm 
WHERE pm.ProductModelID = pmpdc.ProductModelID) as ProductName,
(SELECT pd.Description
FROM Production.ProductDescription Pd
WHERE pd.ProductDescriptionID = pmpdc.ProductDescriptionID) as ProductDesc
FROM Production.ProductModelProductDescriptionCulture pmpdc
WHERE pmpdc.CultureID in ('ar') 

-- 13.	 Find first 20 employees who joined very early in the company
SELECT TOP 20 e.BusinessEntityID,
	CONCAT_WS( ' ' , p.FirstName , p.LastName ) as EmpName,
	e.HireDate 
FROM HumanResources.Employee e ,
Person.Person p
WHERE p.BusinessEntityID = e.BusinessEntityID
ORDER BY e.HireDate

-- 14.	Find most trending product based on sales and purchase.
SELECT TOP 1 
    p.ProductID, 
    p.Name AS ProductName, 
    SUM(sod.OrderQty) AS TotalSales, 
    SUM(pod.OrderQty) AS TotalPurchases
FROM Production.Product p,
Sales.SalesOrderDetail sod,
Purchasing.PurchaseOrderDetail pod
WHERE p.ProductID = sod.ProductID
and p.ProductID = pod.ProductID
GROUP BY p.ProductID, p.Name
ORDER BY SUM(sod.OrderQty) DESC; 

-- **************************************** Sub Query*******************************************************

-- 15 display EMP name, territory name, saleslastyear salesquota and bonus
SELECT 
    e.BusinessEntityID,
    CONCAT_WS( ' ' , p.FirstName , p.LastName ) as EmpName,
    st.Name AS TerritoryName,
    sp.SalesLastYear,
    sp.SalesQuota,
    sp.Bonus
FROM Sales.SalesPerson sp,
 HumanResources.Employee e,
  Person.Person p,
  Sales.SalesTerritory st 
WHERE sp.BusinessEntityID = e.BusinessEntityID
and e.BusinessEntityID = p.BusinessEntityID
and sp.TerritoryID = st.TerritoryID
ORDER BY sp.SalesLastYear DESC; 

-- 16. display EMP name, territory name, saleslastyear salesquota and bonus from Germany and United Kingdom
SELECT 
    e.BusinessEntityID,
    CONCAT_WS(' ', p.FirstName, p.LastName) AS EmpName,
    st.Name AS TerritoryName,
    sp.SalesLastYear,
    sp.SalesQuota,
    sp.Bonus
FROM Sales.SalesPerson sp, 
     HumanResources.Employee e, 
     Person.Person p, 
     Sales.SalesTerritory st
WHERE sp.BusinessEntityID = e.BusinessEntityID
AND e.BusinessEntityID = p.BusinessEntityID
AND sp.TerritoryID = st.TerritoryID
AND st.CountryRegionCode IN ('DE', 'GB')  
ORDER BY sp.SalesLastYear DESC;


-- 17 Find all employee who worked in all North America territory.
select * from Sales.SalesTerritory; --territory id ,Group
select * from Sales.SalesTerritoryHistory;--business entity id , territory id 
select * from HumanResources.Employee;--business entity id
select * from Person.Person;--business entity id

select p.FirstName,p.LastName,st.Name,st.[Group]
from Sales.SalesTerritory st,
	 Sales.SalesTerritoryHistory sth,
	 HumanResources.Employee e,
	 Person.Person p
where p.BusinessEntityID=e.BusinessEntityID and 
	  st.TerritoryID=sth.TerritoryID and
	  sth.BusinessEntityID=e.BusinessEntityID and 
	  st.[Group]='North America'

-- 18. find all products in the cart
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    sod.OrderQty AS QuantityInCart,
    sod.UnitPrice,
    soh.Status AS OrderStatus
FROM Production.Product p, 
     Sales.SalesOrderDetail sod, 
     Sales.SalesOrderHeader soh
WHERE p.ProductID = sod.ProductID
AND sod.SalesOrderID = soh.SalesOrderID
AND soh.Status < 5; 


-- 19.	 find all the products with special offer
SELECT 
    p.ProductID,
    p.Name AS ProductName,
    so.Type AS OfferType,
    so.DiscountPct AS DiscountPercentage,
    so.StartDate,
    so.EndDate
FROM Production.Product p, 
     Sales.SpecialOfferProduct sop, 
     Sales.SpecialOffer so
WHERE p.ProductID = sop.ProductID
AND sop.SpecialOfferID = so.SpecialOfferID;


-- 20.	 find all employees name , job title, card details whose credit card expired in the month 11 and year as 2008
SELECT 
    e.BusinessEntityID,
    CONCAT_WS(' ', p.FirstName, p.LastName) AS EmployeeName,
    e.JobTitle,
    cc.CardNumber,
    cc.ExpMonth,
    cc.ExpYear
FROM HumanResources.Employee e, 
     Person.Person p, 
     Sales.CreditCard cc, 
     Sales.PersonCreditCard pcc
WHERE e.BusinessEntityID = p.BusinessEntityID
AND p.BusinessEntityID = pcc.BusinessEntityID
AND pcc.CreditCardID = cc.CreditCardID
AND cc.ExpMonth = 11
AND cc.ExpYear = 2008;


-- 21. Find the employee whose payment might be revised  
SELECT BusinessEntityID , COUNT(*) as RevisedCount
FROM HumanResources.EmployeePayHistory
GROUP BY BusinessEntityID
HAVING COUNT(*) > 1 

--22. Find total standard cost for the active Product. (Product cost history)
SELECT 
    SUM(pch.StandardCost) AS TotalStdCost
FROM Production.ProductCostHistory pch, 
     Production.Product p
WHERE pch.ProductID = p.ProductID
AND pch.EndDate IS NULL;  


-- **************************************** Joins *******************************************************

--23.	Find the personal details with address and address type(hint: Business Entiry Address , Address, Address type)
SELECT p.FirstName,
p.LastName,
at.Name,
a.AddressLine1
FROM Person.BusinessEntityAddress bea,
Person.Address a , 
Person.AddressType at,
Person.Person p 
WHERE bea.AddressID = a.AddressID
and bea.AddressTypeID = at.AddressTypeID
and bea.BusinessEntityID = p.BusinessEntityID 

-- 24. Find the name of employees working in group of North America territory
select p.FirstName,p.LastName,st.Name,st.[Group]
from Sales.SalesTerritory st,
	 Sales.SalesTerritoryHistory sth,
	 HumanResources.Employee e,
	 Person.Person p
where p.BusinessEntityID=e.BusinessEntityID and 
	  st.TerritoryID=sth.TerritoryID and
	  sth.BusinessEntityID=e.BusinessEntityID and 
	  st.[Group]='North America'

-- **************************************** Group By *******************************************************
-- 25.	 Find the employee whose payment is revised for more than once     
SELECT e.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.LastName) AS EmployeeName, 
       COUNT(sph.BusinessEntityID) AS RevisionCnt
FROM HumanResources.Employee e, 
     Person.Person p, 
     HumanResources.EmployeePayHistory sph
WHERE e.BusinessEntityID = p.BusinessEntityID
AND e.BusinessEntityID = sph.BusinessEntityID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName
HAVING COUNT(sph.BusinessEntityID) > 1; 


-- 26. display the personal details of  employee whose payment is revised for more than once.
SELECT e.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.LastName) AS EmployeeName, 
       p.PersonType, 
       p.EmailPromotion, 
       e.JobTitle
FROM HumanResources.Employee e, 
     Person.Person p, 
     HumanResources.EmployeePayHistory sph
WHERE e.BusinessEntityID = p.BusinessEntityID
AND e.BusinessEntityID = sph.BusinessEntityID
GROUP BY e.BusinessEntityID, p.FirstName, p.LastName, p.PersonType, p.EmailPromotion, e.JobTitle
HAVING COUNT(sph.BusinessEntityID) > 1; 


-- 27.	Which shelf is having maximum quantity (product inventory)
SELECT TOP 1 pii.Shelf , SUM(pii.Quantity) as MaxQnt
FROM Production.ProductInventory pii
GROUP BY pii.Shelf
ORDER BY SUM(pii.Quantity) DESC

-- 28.	Which shelf is using maximum bin(product inventory)
SELECT TOP 1 pii.Shelf , SUM(pii.Bin)as MaxQnt
FROM Production.ProductInventory pii
GROUP BY pii.Shelf
ORDER BY SUM(pii.Bin) DESC

-- 29.	Which location is having minimum bin (product inventory)
SELECT TOP 2 pii.LocationID , SUM(pii.Bin)as MaxQnt
FROM Production.ProductInventory pii
GROUP BY pii.LocationID
ORDER BY SUM(pii.Bin) 

-- 30.	Find out the product available in most of the locations (product inventory)
SELECT  pii.ProductID , 
       COUNT(DISTINCT pii.LocationID) 
FROM Production.ProductInventory pii
GROUP BY pii.ProductID 
ORDER By COUNT(pii.LocationID) DESC 

-- 31.	Which sales order is having most order qualtity.
SELECT TOP 1 so.SalesOrderID, 
       SUM(sod.OrderQty) AS TotalOrderQnt
FROM Sales.SalesOrderHeader so, 
     Sales.SalesOrderDetail sod
WHERE so.SalesOrderID = sod.SalesOrderID
GROUP BY so.SalesOrderID
ORDER BY TotalOrderQnt DESC
 
--32. find the duration of payment revision on every interval  (inline view) Output must be as given format
SELECT eph.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.LastName) AS EmployeeName,
       eph.RateChangeDate,
       LAG(eph.RateChangeDate) OVER (PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate) AS PrevRevDate,
       DATEDIFF(DAY, 
                LAG(eph.RateChangeDate) OVER (PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate), 
                eph.RateChangeDate) AS DurationBetweenRevisions
FROM HumanResources.EmployeePayHistory eph, 
     Person.Person p
WHERE eph.BusinessEntityID = p.BusinessEntityID
ORDER BY eph.BusinessEntityID, eph.RateChangeDate;


--33. check if any employee from jobcandidate table is having any payment revisions
SELECT jc.BusinessEntityID , COUNT(*) as RevisedCount
FROM HumanResources.JobCandidate jc ,
HumanResources.Employee e
WHERE jc.BusinessEntityID = e.BusinessEntityID
GROUP BY jc.BusinessEntityID
HAVING COUNT(*) > 0 

-- 34. check the department having more salary revision 
SELECT d.DepartmentID, d.Name , COUNT(*) salRev
FROM HumanResources.Department d , 
HumanResources.Employee e ,
HumanResources.EmployeeDepartmentHistory  edh
WHERE edh.DepartmentID = d.DepartmentID
and edh.BusinessEntityID = e.BusinessEntityID 
GROUP BY d.Name , d.DepartmentID
HAVING COUNT(*) > 0
ORDER BY COUNT(*) DESC

-- 35.  check the employee whose payment is not yet revised 
SELECT e.BusinessEntityID , COUNT(*) as notRevised 
FROM HumanResources.EmployeePayHistory  eph,
HumanResources.Employee e 
WHERE eph.BusinessEntityID = e.BusinessEntityID
GROUP BY e.BusinessEntityID 
HAVING COUNT(*) = 0

-- Inline View 
SELECT JobTitle, COUNT(*) 
FROM
(SELECT e.JobTitle ,
eph.BusinessEntityID,
COUNT(*) cnt 
FROM HumanResources.Employee e,
HumanResources.EmployeePayHistory eph
WHERE  e.BusinessEntityID = eph.BusinessEntityID
GROUP BY e.JobTitle,
eph.BusinessEntityID
HAVING COUNT(*) > 1 )as t 
GROUP BY t.JobTitle

-- 36.	 find the job title having more revised payments
SELECT TOP 1 e.JobTitle,  COUNT(*) as RevPayments
FROM HumanResources.Employee e ,
HumanResources.EmployeePayHistory eph
WHERE e.BusinessEntityID = eph.BusinessEntityID
GROUP BY  e.JobTitle 
ORDER BY COUNT(*) DESC

-- 37. find the employee whose payment is revised in shortest duration
SELECT eph.BusinessEntityID , 
	eph.RateChangeDate,
	ROW_NUMBER() OVER ( PARTITION BY eph.BusinessEntityID ORDER BY eph.RateChangeDate) as Ranks
FROM Person.Person p ,
	 HumanResources.EmployeePayHistory eph 
WHERE eph.BusinessEntityID = p.BusinessEntityID

WITH PayHistory AS (
    SELECT BusinessEntityID, 
           RateChangeDate, 
           LEAD(RateChangeDate) OVER (PARTITION BY BusinessEntityID ORDER BY RateChangeDate) AS NextChangeDate
    FROM HumanResources.EmployeePayHistory
)
SELECT TOP 1 BusinessEntityID, 
             DATEDIFF(DAY, RateChangeDate, NextChangeDate) AS Duration
FROM PayHistory
WHERE NextChangeDate IS NOT NULL
ORDER BY Duration ASC;

-- 38. find the colour wise count of the product (tbl: product)
SELECT p.color,  COUNT(*)
FROM Production.Product p 
GROUP BY p.Color

-- 39.	 find out the product who are not in position to sell (hint: check the sell start and end date)
SELECT p.Name
FROM Production.Product p 
WHERE p.SellEndDate is not null
-- and p.SellEndDate > GETDATE()

-- 40 find the class wise, style wise average standard cost 
SELECT p.Style , p.Class , AVG(p.StandardCost)
FROM Production.Product p 
GROUP BY p.Style , p.Class

--41  check colour wise standard cost
SELECT p.Color , AVG(p.StandardCost)
FROM Production.Product p 
GROUP BY p.Color

 -- 42 find the product line wise standard cost 
 SELECT p.ProductLine , AVG(p.StandardCost)
FROM Production.Product p 
GROUP BY p.ProductLine

-- 43 Find the state wise tax rate (hint: Sales.SalesTaxRate, Person.StateProvince) 
SELECT sr.StateProvinceID, sp.Name, AVG(sr.TaxRate)
FROM Sales.SalesTaxRate sr , Person.StateProvince sp
WHERE sr.StateProvinceID = sp.StateProvinceID
GROUP BY sp.Name , sr.StateProvinceID

-- 44 Find the department wise count of employees 
SELECT d.Name , COUNT(*) NoOfEmp 
FROM HumanResources.Department d , HumanResources.EmployeeDepartmentHistory edh
WHERE d.DepartmentID = edh.DepartmentID
GROUP BY d.Name

--45.	Find the department which is having more employees
SELECT TOP 1 d.Name AS DeptName, 
       COUNT(e.BusinessEntityID) AS EmpCnt
FROM HumanResources.Employee e, 
     HumanResources.EmployeeDepartmentHistory edh, 
     HumanResources.Department d
WHERE e.BusinessEntityID = edh.BusinessEntityID
AND edh.DepartmentID = d.DepartmentID
GROUP BY d.Name
ORDER BY EmpCnt DESC

--46.	Find the job title having more employees
SELECT TOP 1 e.JobTitle, 
       COUNT(e.BusinessEntityID) AS EmpCnt
FROM HumanResources.Employee e
GROUP BY e.JobTitle
ORDER BY EmpCnt DESC

--47.	Check if there is mass hiring of employees on single day
SELECT HireDate, 
       COUNT(BusinessEntityID) AS EmpCnt
FROM HumanResources.Employee
GROUP BY HireDate
HAVING COUNT(BusinessEntityID) > 10  
ORDER BY EmpCnt DESC;

--48.	Which product is purchased more? (purchase order details)
SELECT TOP 1 p.Name AS ProductName, 
       SUM(pod.OrderQty) AS TotalPurchased
FROM Purchasing.PurchaseOrderDetail pod, 
     Production.Product p
WHERE pod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalPurchased DESC

--49.	Find the territory wise customers count   (hint: customer)
SELECT st.Name AS TerritoryName, 
       COUNT(c.CustomerID) AS CustomerCount
FROM Sales.Customer c, 
     Sales.SalesTerritory st
WHERE c.TerritoryID = st.TerritoryID
GROUP BY st.Name
ORDER BY CustomerCount DESC;

--50.	Which territory is having more customers (hint: customer)
SELECT TOP 1 st.Name AS TerritoryName, 
       COUNT(c.CustomerID) AS CustomerCount
FROM Sales.Customer c, 
     Sales.SalesTerritory st
WHERE c.TerritoryID = st.TerritoryID
GROUP BY st.Name
ORDER BY CustomerCount DESC

--51.	Which territory is having more stores (hint: customer)
SELECT TOP  1 st.Name AS TerritoryName, 
       COUNT(c.CustomerID) AS StoreCount
FROM Sales.Customer c, 
     Sales.SalesTerritory st
WHERE c.TerritoryID = st.TerritoryID
AND c.StoreID IS NOT NULL 
GROUP BY st.Name
ORDER BY StoreCount DESC

--52.	 Is there any person having more than one credit card (hint: PersonCreditCard)
SELECT per.BusinessEntityID, 
       CONCAT_WS(' ', per.FirstName, per.LastName) AS PersonName,
       COUNT(pc.CreditCardID) AS CreditCardCount
FROM Sales.PersonCreditCard pc, 
     Person.Person per
WHERE pc.BusinessEntityID = per.BusinessEntityID
GROUP BY per.BusinessEntityID, per.FirstName, per.LastName
HAVING COUNT(pc.CreditCardID) > 1
ORDER BY CreditCardCount DESC;

--53.	Find the product wise sale price (sales order details)
SELECT p.Name AS ProductName, 
       SUM(sod.LineTotal) AS TotalSales
FROM Sales.SalesOrderDetail sod, 
     Production.Product p
WHERE sod.ProductID = p.ProductID
GROUP BY p.Name
ORDER BY TotalSales DESC;

--54.	Find the total values for line total product having maximum order
SELECT p.Name AS ProductName, 
       SUM(sod.LineTotal) AS TotalSalesVal
FROM Sales.SalesOrderDetail sod, 
     Production.Product p
WHERE sod.ProductID = p.ProductID
AND sod.OrderQty = (SELECT MAX(OrderQty) FROM Sales.SalesOrderDetail)
GROUP BY p.Name
ORDER BY TotalSalesVal DESC;

--******************************************* Date queries ***********************************************
-- 55.	Calculate the age of employees
SELECT e.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.LastName) AS EmployeeName,
       DATEDIFF(YEAR, e.BirthDate, GETDATE()) AS Age
FROM HumanResources.Employee e, 
     Person.Person p
WHERE e.BusinessEntityID = p.BusinessEntityID;

--56.	Calculate the year of experience of the employee based on hire date
SELECT e.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.LastName) AS EmpName,
       DATEDIFF(YEAR, e.HireDate, GETDATE()) AS YrOfExp
FROM HumanResources.Employee e, 
     Person.Person p
WHERE e.BusinessEntityID = p.BusinessEntityID

--57.	Find the age of employee at the time of joining
SELECT e.BusinessEntityID, 
       CONCAT_WS(' ', p.FirstName, p.LastName) AS EmployeeName,
       DATEDIFF(YEAR, e.BirthDate, e.HireDate) AS AgeAtJoining
FROM HumanResources.Employee e, 
     Person.Person p
WHERE e.BusinessEntityID = p.BusinessEntityID;

--58.	Find the average age of male and female
SELECT e.Gender, 
       AVG(DATEDIFF(YEAR, e.BirthDate, GETDATE())) AS AvgAge
FROM Person.Person p, 
     HumanResources.Employee e
WHERE e.BusinessEntityID = p.BusinessEntityID
GROUP BY e.Gender;

--59.	 Which product is the oldest product as on the date (refer  the product sell start date)
SELECT TOP 1 p.Name AS ProductName, 
       p.SellStartDate
FROM Production.Product p
ORDER BY p.SellStartDate ASC

--60.	 Display the product name, standard cost, and time duration for the same cost. (Product cost history)
SELECT p.Name AS ProductName, 
       pch.StandardCost, 
       DATEDIFF(DAY, pch.StartDate, COALESCE(pch.EndDate, GETDATE())) AS DurationDays
FROM Production.ProductCostHistory pch, 
     Production.Product p
WHERE pch.ProductID = p.ProductID;

--61.	Find the purchase id where shipment is done 1 month later of order date  
 SELECT PurchaseOrderID
FROM Purchasing.PurchaseOrderHeader
WHERE DATEDIFF(MONTH, OrderDate, ShipDate) = 1;

--62.	Find the sum of total due where shipment is done 1 month later of order date ( purchase order header)
SELECT SUM(TotalDue) AS SumTotalDue
FROM Purchasing.PurchaseOrderHeader
WHERE DATEDIFF(MONTH, OrderDate, ShipDate) = 1;

--63.	 Find the average difference in due date and ship date based on  online order flag
SELECT OnlineOrderFlag, 
       AVG(DATEDIFF(DAY, ShipDate, DueDate)) AS AvgDifference
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag;

--******************************************* Window functions *********************************************
-- 64. display business entity id marital status , gender , vaccation hr , avg vaccation based on marital status 
SELECT BusinessEntityID ,
	MaritalStatus,
	Gender,
	VacationHours,
	avg(VacationHours) OVER (PARTITION BY MaritalStatus  )
FROM HumanResources.Employee 

--65.	Display business entity id, marital status, gender, vacationhr, average vacation based on gender
SELECT BusinessEntityID ,
	MaritalStatus,
	Gender,
	VacationHours,
	OrganizationLevel,
	avg(VacationHours) OVER (PARTITION BY Gender ) avgByGender
FROM HumanResources.Employee 

--66.	Display business entity id, marital status, gender, vacationhr, average vacation based on organizational level
SELECT BusinessEntityID ,
	MaritalStatus,
	Gender,
	VacationHours,
	OrganizationLevel,
	avg(VacationHours) OVER (PARTITION BY OrganizationLevel  ) avgByOrgLevel
FROM HumanResources.Employee 

--67.	Display entity id, hire date, department name and department wise count of employee and count based on organizational level in each dept
SELECT e.BusinessEntityID , e.HireDate, d.Name , e.OrganizationLevel,
COUNT(*) OVER (PARTITION BY d.departmentID) avgByDeptName,
COUNT(*) OVER (PARTITION BY d.departmentID, e.OrganizationLevel) avgByOrgLevel
FROM HumanResources.Employee e , 
	HumanResources.Department d ,
	HumanResources.EmployeeDepartmentHistory edh
WHERE e.BusinessEntityID = edh.BusinessEntityID
and d.DepartmentID = edh.DepartmentID

--68	Display department name, average sick leave and sick leave per department
SELECT d.Name, 
	   e.Gender,
	   e.BusinessEntityID,
	   (SELECT avg(SickLeaveHours)
	   FROM HumanResources.Employee e ),
	   avg(SickLeaveHours) over (PARTITION BY d.DepartmentID) AvgDeptWise
FROM HumanResources.Employee e , 
HumanResources.Department d,
HumanResources.EmployeeDepartmentHistory edh
WHERE e.BusinessEntityID = edh.BusinessEntityID
and d.DepartmentID = edh.DepartmentID
ORDER BY d.Name

--69.	Display the employee details first name, last name,  with total count of various shift done by the person and shifts count per department
SELECT p.BusinessEntityID,
	   p.FirstName,
	   p.LastName,
	   d.Name,
	   edh.ShiftID,
	   COUNT(*) OVER (PARTITION BY d.Name)
FROM  
HumanResources.Department d,
HumanResources.EmployeeDepartmentHistory edh,
Person.Person p
WHERE p.BusinessEntityID = edh.BusinessEntityID
and d.DepartmentID = edh.DepartmentID
ORDER BY p.BusinessEntityID

--70.	Display country region code, group average sales quota based on territory id
SELECT DISTINCT st.CountryRegionCode,
		st.[Group],
		st.Name,
		avg(sp.SalesQuota) OVER (PARTITION BY st.TerritoryID) avgSalesQuota
FROM Sales.SalesTerritory st,
Sales.SalesPerson sp 
WHERE st.TerritoryID = sp.TerritoryID

--71.	Display special offer description, category and avg(discount pct) per the category
SELECT sp.Description,
		sp.Category,
		avg(sp.DiscountPct) OVER (PARTITION BY sp.Category)
FROM Sales.SpecialOffer sp

--72.	Display special offer description, category and avg(discount pct) per the month
SELECT sp.Description,
		sp.Category,
		MONTH(sp.StartDate) SMonth,
		avg(sp.DiscountPct) OVER (PARTITION BY MONTH(sp.StartDate)) DiscountstrtDate,
		MONTH(sp.EndDate) EMonth,
		avg(sp.DiscountPct) OVER (PARTITION BY MONTH(sp.EndDate)) DiscountEndDate
FROM Sales.SpecialOffer sp

--73.	Display special offer description, category and avg(discount pct) per the year
SELECT 
    so.Description AS SpecialOfferDescription,
    so.Category,
    YEAR(soh.OrderDate) AS OrderYear,
    so.DiscountPct,
    AVG(so.DiscountPct) OVER (PARTITION BY YEAR(soh.OrderDate), so.Description, so.Category) AS AvgDiscountPct
FROM Sales.SpecialOffer so, 
     Sales.SalesOrderHeader soh, 
     Sales.SalesOrderDetail sod
WHERE so.SpecialOfferID = sod.SpecialOfferID
AND soh.SalesOrderID = sod.SalesOrderID
ORDER BY OrderYear DESC;

--74.	Display special offer description, category and avg(discount pct) per the type
SELECT 
    so.Description AS SpecialOfferDescription,
    so.Category,
    so.Type,
    so.DiscountPct,
    AVG(so.DiscountPct) OVER (PARTITION BY so.Type) AS AvgDiscountPct
FROM Sales.SpecialOffer so
ORDER BY so.Type;

--75.	Using rank and dense rand find territory wise top sales person
SELECT 
    sp.BusinessEntityID,
    CONCAT_WS(' ', p.FirstName, p.LastName) AS SalesPersonName,
    st.Name AS TerritoryName,
    sp.SalesYTD,
    RANK() OVER (PARTITION BY sp.TerritoryID ORDER BY sp.SalesYTD DESC) AS Rank_Pos,
    DENSE_RANK() OVER (PARTITION BY sp.TerritoryID ORDER BY sp.SalesYTD DESC) AS DenseRank_Pos
FROM Sales.SalesPerson sp, 
     Person.Person p, 
     Sales.SalesTerritory st
WHERE sp.BusinessEntityID = p.BusinessEntityID
AND sp.TerritoryID = st.TerritoryID
ORDER BY st.Name, Rank_Pos;
