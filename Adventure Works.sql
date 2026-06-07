create database Adventure_works;

use adventure_works;

select * from dimcustomer;
select * from dimdate;

create view sales_data as 
select * from factinternetsales
Union all
select * from fact_internet_sales_new;

select * from sales_data;

select p.productkey, 
       p.EnglishProductName, 
       ps.EnglishProductSubcategoryName, 
       pc.EnglishProductCategoryName
from dimproduct p left join dimproductsubcategory ps 
on p.ProductSubcategoryKey = ps.ProductSubcategoryKey
left join dimproductcategory pc 
on ps.ProductCategoryKey = pc.ProductCategoryKey;

/* ProductSubcategoryKey is TEXT in product table and is INT in productsubcategorytable.
Use Alter to change the datatype from TEXT to INT.
Update is used to replace blank values with NULL. And than use Alter to change the datatype
*/

UPDATE dimproduct
SET ProductSubcategoryKey = NULL
WHERE ProductSubcategoryKey = '';

ALTER TABLE dimproduct
MODIFY ProductSubcategoryKey INT;


/*CREATE VIEW final_sales AS
SELECT s.*,
       c.FirstName,
       c.LastName,
       p.EnglishProductName,
       d.CalendarYear,
       d.MonthNumberOfYear,
       t.SalesTerritoryRegion
FROM sales_data s
Left JOIN dimcustomer c ON s.CustomerKey = c.CustomerKey
Left JOIN dimproduct p ON s.ProductKey = p.ProductKey
Left JOIN dimdate d ON s.OrderDateKey = d.DateKey
Left JOIN dimsalesterritory t ON s.SalesTerritoryKey = t.SalesTerritoryKey; */

CREATE VIEW Final_sales_data AS
SELECT f.*,
       c.FirstName,
       c.LastName,
       p.EnglishProductName,
       d.CalendarYear,
       d.MonthNumberOfYear,
       t.SalesTerritoryRegion,
       (f.UnitPrice * f.OrderQuantity * (1 - f.UnitPriceDiscountPct)) AS SalesAmount,
       (p.standardcost * f.OrderQuantity) AS ProductionCost,
       ((f.UnitPrice * f.OrderQuantity * (1 - f.UnitPriceDiscountPct)) - (p.standardcost * f.OrderQuantity)) AS Profit
FROM sales_data f
JOIN dimcustomer c ON f.CustomerKey = c.CustomerKey
JOIN dimproduct p ON f.ProductKey = p.ProductKey
JOIN dimdate d ON f.OrderDateKey = d.DateKey
JOIN dimsalesterritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey;

select * from final_sales_data;


SELECT CalendarYear, MonthNumberOfYear, EnglishMonthName
FROM dimdate;


select Englishmonthname,
case
 when monthnumberofyear >= 4 then monthnumberofyear - 3
 else monthnumberofyear + 9
end as FinancialMonth
from dimdate;


select EnglishMonthName,
case
 when monthnumberofyear between 4 and 6 then "FQ1"
 when monthnumberofyear between 7 and 9 then "FQ2"
 when monthnumberofyear between 10 and 12 then "FQ3"
 else "FQ4"
 end as FinancialQuarter from dimdate;	
 
 
SELECT SUM(SalesAmount) FROM final_sales_data;


SELECT CalendarYear, SUM(SalesAmount)
FROM final_sales_data
GROUP BY CalendarYear;


SELECT EnglishProductName, SUM(SalesAmount)
FROM final_sales_data
GROUP BY EnglishProductName;


SELECT SalesTerritoryRegion, SUM(SalesAmount)
FROM final_sales_data
WHERE SalesTerritoryRegion IN ('Northwest', 'Central')
GROUP BY SalesTerritoryRegion;


SELECT DISTINCT EnglishProductName, sum(salesAmount)
FROM final_sales_data
WHERE EnglishProductName LIKE '%Road%'
group by EnglishProductName;


SELECT CalendarYear, EnglishProductName, SUM(SalesAmount) AS TotalSales
FROM final_sales_data
GROUP BY CalendarYear, EnglishProductName
ORDER BY calendaryear, TotalSales DESC
limit 5;


SELECT CustomerKey, AVG(SalesAmount) AS AvgOrderValue
FROM final_sales_data
GROUP BY CustomerKey;


SELECT SalesTerritoryRegion, COUNT(*) AS TotalOrders, SUM(SalesAmount) AS TotalSales
FROM final_sales_data
GROUP BY SalesTerritoryRegion;


SELECT CustomerKey, salesterritoryregion, COUNT(*) AS OrderCount,
CASE 
WHEN COUNT(*) > 1 THEN 'Repeat Customer'
ELSE 'One-Time Customer'
END AS CustomerType
FROM final_sales_data
GROUP BY CustomerKey, salesterritoryregion;
