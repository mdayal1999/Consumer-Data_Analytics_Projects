use superstore
select * from superstore

-- Superstore Sales Analysis--
	
-- Q1 Show all the records--
select * from superstore

-- Q2 Show only Order ID Sales, and Profit--
select `Order ID`, Sales, Profit from superstore

-- Q3 Retrieve all orders where sales is greater than 500--
select `order id`,Sales from superstore
where sales >500

-- Q4 Find all orders ship using second class--
select `order id`, `Ship Mode` from superstore
where `ship mode` = 'Second Class'

-- Q5 List Unique Values in Ship Mode-- 
select distinct`ship mode` from superstore

-- Q6 Show top 10 high sales record--
select Sales as highest_sales from superstore
order by sales desc
limit 10

-- Q7 Get all orders placed from California--
select Count(State), State from superstore
where State = 'California'

-- Q8 Show all records where discount is greater than 0.2 --
select * from superstore 
where Discount > 0.2

-- Q9 Count how many unique customers are in the dataset --
select count(distinct `customer id`) as unique_customer from superstore

-- Q10 Find the Earliest and Latest Order Date --
select Max(`order date`) as Latest_Date,
Min(`order date`) as Earliest_Date
from superstore

-- Q11 Find Total Sale for entire dataset-- 
select sum(Sales) as Total_Sales from superstore

-- Q12 Find average profit per order--
select `order id`, avg(Profit) as avg_profit_per_order
from superstore
group by `order id`

-- Q13 Show total quantity per category--
select Category, sum(Quantity) as total_quantity
from superstore
group by Category

-- Q14 Get Total Sales by region, sorted by highest sales first--
select Region, Sum(sales) as total_sales_by_region from superstore
group by Region
order by total_sales_by_region DESC
limit 10

-- Q15 Top 5 cities with  the most orders--
select City, Count(`order id`) as Total_Order from superstore
group by City
order by Total_Order Desc
limit 5

-- Q16 Get hom many orders ship mode has--
select `Ship Mode`, Count(`order id`) as Total_Order from superstore
group by `Ship Mode`
order by Total_Order Desc

-- Q17 Find total profit and avg discount per sub category--
select `sub-category`, sum(Profit) as total_profit, avg(Discount) as avg_discount
from superstore 
group by `sub-category`

-- Q18  Identify the category with the highest total sales--
select Category, Sum(Sales) as highest_sales from superstore
group by Category
order by highest_sales Desc

-- Checking Order_Date Data Type --
select data_type from
information_schema.columns
where table_name = 'superstore'
and column_name = 'Order Date'

-- Converting Data_Type --


select
  `order date`,
 case
	when `Order Date` like '%/%/%' then STR_TO_DATE(`Order Date`, '%m/%d/%y')
	when `Order Date` like '____-__-__' then STR_TO_DATE(`Order Date`, '%y-%m-%d')
	when `Order Date` like '%-%-%' then STR_TO_DATE(`Order Date`, '%d-%b-%y')
	else null
end as converted_date
from superstore

ALTER TABLE superstore 
add column converted_date DATE 

select * from superstore

UPDATE superstore
SET CONVERTED_DATE = CASE
    WHEN `Order Date` LIKE '%/%/%'
         THEN STR_TO_DATE(`Order Date`, '%m/%d/%Y')
    WHEN `Order Date` LIKE '____-__-__'
         THEN STR_TO_DATE(`Order Date`, '%Y-%m-%d')
    WHEN `Order Date` LIKE '%-%-%'
         THEN STR_TO_DATE(`Order Date`, '%d-%b-%Y')
    ELSE NULL
END;

-- Q19 Find Monthly Sales --
select data_type from
information_schema.columns
where table_name = 'superstore'
and column_name = 'CONVERTED_DATE'

select 
Format ('CONVERTED_DATE', 'yyyy-mm') as Month,
sum(Sales) as Total_Monthly_Sales
from superstore
group by Format ('CONVERTED_DATE', 'yyyy-mm')
order by Month;


SELECT 
    DATE_FORMAT(CONVERTED_DATE, '%Y-%m') AS `Month`,
    SUM(Sales) AS Total_Monthly_Sales
FROM superstore
GROUP BY DATE_FORMAT(CONVERTED_DATE, '%Y-%m')
ORDER BY `Month`;


SELECT 
    DATE_FORMAT(CONVERTED_DATE, '%Y-%m') AS `Month`,
    SUM(Sales) AS Total_Monthly_Sales
FROM superstore
where year(CONVERTED_DATE) = 2014
GROUP BY DATE_FORMAT(CONVERTED_DATE, '%Y-%m')
ORDER BY `Month`;

-- Q20 get total profit per state where profit > 5000--
select State, Sum(Profit) as total_profit
from superstore
where Profit > 5000
group by State

-- splitting the Table  for joins questions--

CREATE TABLE orders (
    OrderID VARCHAR(50) PRIMARY KEY,
    OrderDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(50),
    CustomerName VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    Region VARCHAR(50),
    State VARCHAR(50),
    City VARCHAR(50),
    PostalCode int
);

INSERT INTO Orders (OrderID, OrderDate, ShipMode, CustomerID, CustomerName, Segment, Country, Region, State, City, PostalCode)
SELECT DISTINCT
    `Order ID`,
    `CONVERTED_DATE`,
    `Ship Mode`,
    `Customer ID`,
    `Customer Name`,
    Segment,
    Country,
    Region,
    State,
    City,
    `Postal Code`
FROM superstore;

select* from orders


CREATE TABLE products (
    ProductDetailID INT AUTO_INCREMENT PRIMARY KEY,
    ProductID VARCHAR(50),
    OrderID VARCHAR(50),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    ProductName VARCHAR(255),
    Sales DECIMAL(14,6),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(14,6),
    FOREIGN KEY (OrderID) REFERENCES orders(OrderID)
);
INSERT INTO products (ProductID, OrderID, Category, SubCategory, ProductName, Sales, Quantity, Discount, Profit)
SELECT DISTINCT
    `Product ID`,
    `Order ID`,
    Category,
    `Sub-Category`,
    `Product Name`,
    Sales,
    Quantity,
    Discount,
    Profit
FROM superstore;

-- Q21 Create a query to join orders and products based on order ID --
select * from orders o
join products p on o.OrderID=p.OrderID

-- Q22 Show each customer with their products ordered --
Select
 o.CustomerName,
 p.ProductName,
 p.Category,
 p.SubCategory
from orders o
join products p on o.OrderID=p.OrderID
order by o.CustomerName;

-- Q23 Find Total Sales by Customers -- 
select
 o.CustomerName,
 sum(p.Sales) as total_sales
from orders o
join products p on o.OrderID=p.OrderID
group by o.CustomerName
order by o.CustomerName asc;

-- Q24 Find customers who ordered products from more than 2 categories
select
 o.CustomerName,
 count(Distinct p.Category) as Category_Count
from orders o 
join products p on o.OrderID=p.OrderID
group by o.Customername
having count(Distinct p.Category)>2
order by Category_Count asc;
 
-- Q25 Find orders where sales are above the overall avg sales.
select `Order ID`, Sales
from superstore
where Sales > (select avg(Sales) from superstore)

-- Q26 Find all customers whose total profit is greater than average profit of all customers--
select `Customer Name`, Sum(Profit) as Total_Profit
from superstore
group by `Customer Name`
having Total_Profit > (select avg(Profit) from superstore)
where profit > (select avg(Profit) from superstore)

-- Q27 Find the second highest sales value in the dataset--
select max(Sales) as second_highest_sales from superstore
where Sales < (select max(Sales) from superstore)

-- Q28 Get the list of states that have total sales greater than 20000--
select State, Sum(Sales)
from superstore
group by State
having sum(Sales) > (select sum(Sales) > 20000 from superstore)
order by Sum(Sales) desc

-- Q29 Find the product name that has highest qty sold--
select `Product Name`, max(Quantity) as highest_qty
from superstore
group by `Product Name`
order by highest_qty desc
limit 1

-- Q30 Show all orders that belong to the top 3 customers by total sales--
select `Customer Name`, sum(sales) as total_sales
from superstore
group by `Customer Name`
order by `total_sales` DESC
limit 3

-- Q31 Find the profit margin for each order--
select `Order ID`, `Product ID`, Profit,
round((Profit/Sales)*100, 2) as profit_margin
from superstore

-- Q32 Identify loss making orders--
select `order id`,
`product id`,
Sales,
Profit
from superstore 
where Profit < 0
order by Profit

-- Q33 Find the % contribution of each category to total sales --
select 
 Category,
 round((sum(Sales)/(select sum(Sales) from superstore))*100, 2) as perc_contribution
from superstore
group by Category
order by perc_contribution DESC;

-- Q34 Calculate yoy Sales Growth --
select
	Year(`CONVERTED_DATE`) as Year,
    sum(Sales) as Total_Sales,
    Lag(sum(Sales)) over (order by Year(`CONVERTED_DATE`)) as Previous_year_sales,
    Round(((sum(Sales) - Lag(sum(Sales)) over (order by Year(`CONVERTED_DATE`)))/Lag(sum(Sales)) over (order by Year(`CONVERTED_DATE`)) * 100), 2)
    AS YOY
from superstore
group by year(`CONVERTED_DATE`)
order by Year;
    
-- Q35 Identify the most frequently ordered product in each region--

select Region, `Product Name`, Count(`Product Name`) as Ordered_Product
from superstore
group by Region, `Product Name`
order by Ordered_Product DESC

-- Q36 Assign a row no. to each order sorted by order date--

select `CONVERTED_DATE`,
`Order Date`,
row_number() over(order by `CONVERTED_DATE`) as ROW_NUM
from superstore;

-- Q37 Find the running total of sales for each region--

select 
Region, 
`CONVERTED_DATE`, 
Sales,
Round(Sum(Sales) over (partition by region order by `CONVERTED_DATE`),2) as running_total
from superstore
order by Region, `CONVERTED_DATE`;
 
-- Q38 Rank Customers based on their total sales--
select 
`Customer Name`, 
Sum(Sales) as Total_Sales,
Rank() over(order by Sum(Sales) DESC) as Customer_Sales_Rank
from superstore
group by `Customer Name`
order by Customer_Sales_Rank

-- Q39 For each category, find the product with the highest sales --
select Category, `Product Name`, total_sales
from(
select Category, `Product Name`, sum(sales) as total_sales,
rank() over(partition by Category order by sum(sales) DESC) as Rnk
from superstore
group by Category, `Product Name`
) as ranked
where rnk = 1
order by Category;

-- Q40 M-O-M sales growth--
select
 Year,
 Month,
 Total_Sales,
 Previous_month_sales,
 Round(((Total_Sales - Previous_month_sales)/Previous_month_sales)*100, 2) as MoM_Growth_Sales
from(
select
	Year(`CONVERTED_DATE`) as Year,
    Month(`CONVERTED_DATE`) as Month,
    sum(Sales) as Total_Sales,
    Lag(sum(Sales)) over (order by Year(`CONVERTED_DATE`), Month(`CONVERTED_DATE`)) as Previous_month_sales
from superstore
group by year(`CONVERTED_DATE`), Month(`CONVERTED_DATE`)
)as FINAL
order by Year, Month;

-- Q41 Calculate total sales per customer where sales is greater than 10000--
select `Customer Name`, Sum(Sales) as total_sales
from superstore
group by `Customer Name`
having Sum(Sales) > 10000
order by total_sales desc

OR

with Customersales as
 (select 
 `Customer Name`, 
 Sum(Sales) as total_sales
 from superstore
 group by `Customer Name`)
select * from Customersales
where total_sales > 10000
order by total_sales desc;

-- Q42 Categorise Profit as Case--
select 
	`Order ID`,
    `Customer ID`,
    Profit,
    CASE
		when Profit > 100 then 'High'
        when Profit Between 0 and 100 then 'Medium'
        when Profit < 0 then 'Loss'
	End as Profit_Category
from superstore
order by Profit Desc;

-- Q43 Top 3 Customer per region usinmg CTE + Rank--
with rankedcustomers as (
	select
     Region,
     `Customer Name`,
     sum(Sales),
     Rank() over(partition by Region order by sum(Sales) desc) as rnk
    from superstore
    group by region, `Customer Name`)
select * from rankedcustomers
where rnk <=3
order by Region, rnk    

-- Q44 Most Profitable Segment-- 
select
Segment,
Sum(Profit) as Total_Profit
from superstore
group by Segment
order by Total_Profit desc
limit 1;

    
    
   