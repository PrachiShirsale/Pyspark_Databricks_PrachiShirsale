USE AdventureWorks2022
SELECT * FROM HumanResources.Department;
SELECT * FROM HumanResources.Employee;

---find all employees who are working  under job title Marketing 
SELECT * FROM HumanResources.Employee
WHERE JobTitle LIKE '%Marketing%';


SELECT COUNT(*) as SingleMales FROM 
HumanResources.Employee
WHERE GENDER = 'M' and MaritalStatus = 'S'
;

SELECT *  FROM 
HumanResources.Employee
WHERE SalariedFlag = 1


SELECT *  FROM 
HumanResources.Employee
WHERE VacationHours BETWEEN  70 AND 90

--- find all jobs having title as Designer

---find total employee worked as Technician
SELECT NationalIDNumber FROM HumanResources.Employee
WHERE JobTitle LIKE '%Technician%'

--- display data having NationalIDNumber, job title , marital status , gender for all under marketing Job title.
SELECT NationalIDNumber , JobTitle, MaritalStatus, Gender FROM HumanResources.Employee
WHERE JobTitle LIKE '%Marketing%'

--- find all unique marital status
SELECT DISTINCT MaritalStatus FROM HumanResources.Employee

---find the MAX vacation hrs
SELECT MAX(VacationHours) as MaxVac FROM HumanResources.Employee

--- find the less sick leaves 
SELECT MIN(SickLeaveHours) as MinSL FROM HumanResources.Employee

--- Find all employee from production department 
SELECT * FROM HumanResources.Department
WHERE name = 'Production'

SELECT * FROM HumanResources.EmployeeDepartmentHistory
WHERE DepartmentID = 7   

SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory
WHERE DepartmentID = 7 )

--- Find all department under research and development
SELECT * FROM HumanResources.Department WHERE GroupName = 'Research and Development'

---  Find all employee under research and development 
SELECT COUNT(*) FROM HumanResources.EmployeeDepartmentHistory
WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.EmployeeDepartmentHistory WHERE DepartmentID in (SELECT DepartmentID FROM HumanResources.Department WHERE GroupName = 'Research and Development'))

--- find all employees who work in day shift -- shift 
SELECT * FROM HumanResources.Shift
WHERE Name = 'Day'

--- find all employee who work in day shift 
SELECT * FROM HumanResources.Employee
WHERE BusinessEntityID in(
(SELECT BusinessEntityID 
FROM HumanResources.EmployeeDepartmentHistory
WHERE ShiftID = (SELECT ShiftID FROM HumanResources.Shift
WHERE Name = 'Day')))

--- pay 

--- Find candidate who are not placed
SELECT BusinessEntityID 
FROM HumanResources.JobCandidate 
WHERE BusinessEntityID IS NOT NULL

SELECT * FROM HumanResources.Employee 
WHERE BusinessEntityID IN  (SELECT BusinessEntityID 
FROM HumanResources.JobCandidate 
WHERE BusinessEntityID IS NOT NULL)

--- Find the address of employee
SELECT * FROM Person.Address  
WHERE AddressID IN (SELECT AddressID FROM Person.BusinessEntityAddress WHERE BusinessEntityID IN (SELECT BusinessEntityID FROM HumanResources.Employee))

--- Correlated Query --> when used with select 

---display national_id , first_name , lastname , and department_name , deparment_group
 SELECT BusinessEntityID , 
        DepartmentID, 
		(SELECT NationalIDNumber
		 FROM HumanResources.Employee e 
		 WHERE e.BusinessEntityID = edh.BusinessEntityID),
		(SELECT CONCAT_WS(' ', FirstName , LastName) 
		FROM Person.Person p
		WHERE p.BusinessEntityID = edh.BusinessEntityID) AS FullName, 
		(SELECT  GroupName  
		 FROM HumanResources.Department d 
		 WHERE d.DepartmentID = edh.DepartmentID)AS GroupName , 
		(SELECT  Name  
		 FROM HumanResources.Department d
		 WHERE d.DepartmentID = edh.DepartmentID)AS DeptName 
 FROM HumanResources.EmployeeDepartmentHistory edh

 --- diaplay firstname , lastName , department and shiftType
 SELECT BusinessEntityID,
        (SELECT CONCAT_WS(' ', FirstName , LastName) 
		FROM Person.Person p
		WHERE p.BusinessEntityID = edh.BusinessEntityID) AS FullName, 
		(SELECT  Name  
		 FROM HumanResources.Department d
		 WHERE d.DepartmentID = edh.DepartmentID)AS DeptName,
		(SELECT StartTime 
		 FROM HumanResources.Shift s
		 WHERE s.ShiftID = edh.ShiftID
		) AS StartTime
 FROM HumanResources.EmployeeDepartmentHistory edh 


 -- display product name  and product review 
 SELECT Name ,
        (SELECT Comments 
		FROM Production.ProductReview pr
		WHERE pr.ProductID = p.ProductID ) 
 FROM Production.Product p


 --- find the employee's name , job title , credit card expired in montl 11 and year 
  SELECT BusinessEntityID,
		CreditCardID,
		(SELECT FirstName 
		FROM Person.Person p
		WHERE p.BusinessEntityID = pcc.BusinessEntityID) FirstName,
		(SELECT jobTitle
		FROM HumanResources.Employee d
		WHERE d.BusinessEntityID = pcc.BusinessEntityID) AS JobTitle,
		(SELECT CardType
		FROM Sales.CreditCard cc
		WHERE cc.CreditCardID = pcc.BusinessEntityID 
		) CardTypeCond
 FROM Sales.PersonCreditCard pcc
 WHERE pcc.CreditCardID In (
SELECT cc.CreditCardID 
FROM Sales.CreditCard cc
WHERE cc.ExpMonth = 11 and cc.ExpYear = 2008)

--- display emp name , territory name , group, salesLastYear, SalesQuota , bonus from germanyy and united Kingdom.

---Person.Person--> name 
---Sales.SalesTerritory ---> territory name , Group ,Territoryid 
---sales.salesPerson ---> salesLastYear , salesQuota, bonus

SELECT SalesLastYear,
	   SalesQuota,
	   Bonus,
	   TerritoryID,
	   BusinessEntityID,
	   (SELECT Name
	    FROM Sales.SalesTerritory st 
	    WHERE st.TerritoryID = sp.TerritoryID ),
		(SELECT st.[Group]
	     FROM Sales.SalesTerritory st 
	     WHERE st.TerritoryID = sp.TerritoryID ),
		 (SELECT FirstName
		 FROM Person.Person p
		 WHERE p.BusinessEntityID = sp.BusinessEntityID)
FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN 
( SELECT st.TerritoryID 
FROM Sales.SalesTerritory st 
WHERE st.Name = 'Germany' or st.Name = 'United Kingdom' )


--- Find all employee who worked in all North America territory.
SELECT SalesLastYear,
	   SalesQuota,
	   Bonus,
	   TerritoryID,
	   BusinessEntityID,
	   (SELECT Name
	    FROM Sales.SalesTerritory st 
	    WHERE st.TerritoryID = sp.TerritoryID ),
		(SELECT st.[Group]
	     FROM Sales.SalesTerritory st 
	     WHERE st.TerritoryID = sp.TerritoryID ),
		 (SELECT FirstName
		 FROM Person.Person p
		 WHERE p.BusinessEntityID = sp.BusinessEntityID)
FROM Sales.SalesPerson sp
WHERE sp.TerritoryID IN 
( SELECT st.TerritoryID 
FROM Sales.SalesTerritory st 
WHERE st.[Group] = 'North America' )


--- find all products in the cart

-- Production.product ---> ProductID , Name 
-- Sales.ShoppingCartItem ---> shoppingcartItemID , ShoppingCartID, ProductID 

--Method 1
SELECT ShoppingCartItemID,
		ShoppingCartID,
		ProductID,
		(SELECT Name 
		FROM Production.Product p
		WHERE p.ProductID = cci.ProductID)
FROM Sales.ShoppingCartItem cci

--- find all the products with special offer

SELECT * 
FROM Production.Product p
WHERE p.ProductID IN 
(SELECT sop.ProductID
FROM Sales.SpecialOfferProduct sop)

SELECT * FROM Production.Product

--Join
--- find all the records from production. producation control , Executive and having  birth date more tham 1970 
--- display firstname , add details , job title, dep 

SELECT d.Name , e.BirthDate , e.BusinessEntityID,
(SELECT firstName 
FROM Person.Person p 
WHERE p.BusinessEntityID = e.BusinessEntityID
)
FROM HumanResources.EmployeeDepartmentHistory edh,
HumanResources.Department d,
HumanResources. Employee e
WHERE edh.BusinessEntityID = e.BusinessEntityID
and edh.DepartmentID = d.DepartmentID
and BirthDate > '01-01-1970'
and d.Name in ('Production' , 'Production Control' , 'Executive')


--First join the tables perfectly 
--then add cond and check exec if perfect then move to next cond 
--and select required cols 


-- display national id, job, title , phone number for employee

SELECT e.NationalIDNumber , 
e.JobTitle,
pp.PhoneNumber
FROM 
HumanResources.Employee e,
Person.PersonPhone pp
WHERE e.BusinessEntityID = pp.BusinessEntityID
and JobTitle LIKE '%Research and Development%'


-- find all product id scrapped more 

SELECT wo.ProductID , COUNT(wo.ScrappedQty) as sq , Name
FROM Production.WorkOrder wo,
Production.Product p 
WHERE wo.ProductID = p.ProductID 
AND ScrappedQty  > 0 
GROUP BY wo.ProductID , Name 
Order BY sq DESC

-- find most frequent purchased product 
SELECT pod.ProductID, SUM(OrderQty) oq 
FROM Purchasing.PurchaseOrderDetail pod,
Production.Product p
WHERE pod.ProductID = p.ProductID
GROUP BY pod.ProductID 
ORDER BY oq DESC

-- WHICH product requires more inventory 
SELECT TOP 1  p.ProductID ,  SUM(pin.Quantity) as InvQuantity , p.Name
FROM Production.ProductInventory pin ,
Production.Product p 
WHERE pin.ProductID = p.ProductID
GROUP BY  p.ProductID , p.Name
ORDER BY SUM(pin.Quantity)  DESC

-- 2 Percent 
SELECT TOP 2 percent  p.ProductID ,  SUM(pin.Quantity) as InvQuantity , p.Name
FROM Production.ProductInventory pin ,
Production.Product p 
WHERE pin.ProductID = p.ProductID
GROUP BY  p.ProductID , p.Name
ORDER BY SUM(pin.Quantity)  DESC

--- Most used ship mode 
SELECT sm.ShipMethodID, COUNT(sm.ShipMethodID) as mn, sm.Name 
FROM Purchasing.ShipMethod sm,
Purchasing.PurchaseOrderHeader poh
WHERE sm.ShipMethodID = poh.ShipMethodID
GROUP BY sm.ShipMethodID, sm.Name
ORDER BY mn DESC


-- which currency conversion is more avg end of date rate 
SELECT FromCurrencyCode , ToCurrencyCode , AVG(EndOfDayRate) avgerage
FROM 
Sales.CurrencyRate
GROUP BY FromCurrencyCode , ToCurrencyCode
ORDER BY avgerage DESC

---  Which currency conversion is with top values end of date rate 
SELECT TOP 1 FromCurrencyCode , ToCurrencyCode , MAX(EndOfDayRate) avgerage
FROM 
Sales.CurrencyRate
GROUP BY FromCurrencyCode , ToCurrencyCode
ORDER BY avgerage DESC

-- which special offer was for more duration


--what are those products having more specialOfferProduct
SELECT p.Name , COUNT(sop.SpecialOfferID) as mostOffers , p.ProductID
FROM Sales.SpecialOffer so , Sales.SpecialOfferProduct sop , Production.Product p 
WHERE sop.SpecialOfferID = so.SpecialOfferID  
and sop.ProductID = p.ProductID
GROUP BY p.ProductID , p.Name
ORDER BY  mostOffers DESC

---QB 
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
-- Ans -> 538 Rows 

-- 4. find out the vendor for product   paint, Adjustable Race and blade	

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
-- And 11 Rows


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
-- And ---> 33 rows 

-- 6.  find the tax amt for products where order date and ship date are on the same day 


-- 7.  find the average days required to ship the product based on shipment type. 

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
WHERE s.Name in ('Day'))
-- > 182 rows

-- 9. based on product and product cost history find the name , service provider time and average Standardcost   

SELECT pch.ProductID,
(SELECT p.Name
FROM Production.Product p
WHERE p.ProductID = pch.ProductID) ProductName,
AVG(pch.StandardCost) as avgStdCst,
DATEDIFF(hour, pch.StartDate , pch.EndDate ) as datedif
FROM Production.ProductCostHistory pch
GROUP BY pch.StandardCost , pch.ProductID, pch.StartDate , pch.EndDate


-- 10 

-- 11. find products with average cost more than 500 

-- 12.  find the employee who worked in multiple territory 
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

Production.ProductDescription ---> pdid
Production.ProductModelProductDescription ---> productModelID , ProductDescriptionID , CultureID  --> ar 
Production.ProductModel --> ProductModelID , Name 

SELECT 
FROM Production.ProdutModelProductDescription


 