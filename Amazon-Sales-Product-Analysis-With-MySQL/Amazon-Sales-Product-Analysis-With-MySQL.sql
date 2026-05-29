create database amazon_capstone;
use amazon_capstone;

select*from amazon;

show columns from amazon; 

-- preprossing --

alter table amazon change column `Invoice ID` invoice_id text;
alter table amazon change column `Branch` branch text;
alter table amazon change column `City` city text;
alter table amazon change column `Customer type` customer_type text;
alter table amazon change column `Gender` gender text;
alter table amazon change column `Product line` product_line text;
alter table amazon change column `Unit price` unit_price text;
alter table amazon change column `Quantity` quantity text;
alter table amazon change column `Tax 5%` VAT text;
alter table amazon change column `Total` total text;
alter table amazon change column `Date` date text;
alter table amazon change column `Time` time text;
alter table amazon change column `Payment` payment_method text;
alter table amazon change column `cogs` cogs text;
alter table amazon change column `gross margin percentage` gross_margin_percentage text;
alter table amazon change column `gross income` gross_income text;
alter table amazon change column `Rating` rating text;

alter table amazon modify column invoice_id VARCHAR(30);
alter table amazon modify column branch VARCHAR(5);
alter table amazon modify column city VARCHAR(30);
alter table amazon modify column customer_type VARCHAR(30);
alter table amazon modify column gender VARCHAR(30);
alter table amazon modify column product_line VARCHAR(100);
alter table amazon modify column unit_price DECIMAL(10, 2);
alter table amazon modify column quantity INT;
alter table amazon modify column VAT FLOAT(6, 4);
alter table amazon modify column total DECIMAL(10, 2);
alter table amazon modify column date DATE;
alter table amazon modify column time TIME;
alter table amazon modify column payment_method VARCHAR(30);
alter table amazon modify column cogs DECIMAL(10, 2);
alter table amazon modify column gross_margin_percentage FLOAT(11, 9);
alter table amazon modify column gross_income DECIMAL(10, 2);
alter table amazon modify column rating FLOAT;

select*from amazon;
show columns from amazon; 

select *
from amazon
where invoice_id IS NULL OR branch IS NULL OR city IS NULL OR customer_type IS NULL
    OR product_line IS NULL OR unit_price IS NULL OR quantity IS NULL
    OR VAT IS NULL OR total IS NULL OR date IS NULL OR time IS NULL
    OR payment_method IS NULL OR cogs IS NULL OR gross_margin_percentage IS NULL
    OR gross_income IS NULL OR rating IS NULL;
    
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'amazon'
AND table_schema = 'amazon_capstone';

    
    -- feature engineering--
    
--  Adding  a new column timeofday
alter table amazon add column timeofday VARCHAR(20);
update amazon
set timeofday = CASE
    when hour(time) >= 0 and hour(time) < 12 then  'Morning'
    when hour(time) >= 12 and hour(time) < 18 then 'Afternoon'
    else 'Evening'
end;
select *from amazon;

-- Adding  a new column  dayname
alter table amazon add column dayname VARCHAR(20);
update amazon
set dayname = DATE_FORMAT(date, '%a');
select *from amazon;

-- Adding a new column monthname
alter table amazon add column monthname VARCHAR(20);
update amazon
set monthname = DATE_FORMAT(date, '%b');
select *from amazon;


-- Product Analysis --

-- Count distinct product lines
select COUNT(distinct product_line) as distinct_product_lines from amazon;
select  distinct product_line as distinct_product_lines from amazon;

-- Product lines performing best by total sales
select product_line, SUM(total) as total_sales
from amazon
group by  product_line
order by total_sales desc;

-- Product lines needing improvement by lowest average rating
select product_line, avg(rating) as avg_rating
from amazon
group by product_line
order by avg_rating asc;


-- Sales Analysis --

-- Sales trends by branch 
select branch , sum(total) as overall_sales , avg(rating) as overall_avg_sales from amazon
group by branch
order by branch, overall_sales desc;

-- Sales trends over time (monthly sales)
select monthname, product_line, SUM(total) as monthly_sales from amazon
group by monthname, product_line
order by monthname, monthly_sales desc;

-- Sales of products trends by branch
select branch, product_line, SUM(total) as branch_sales from amazon
group by branch, product_line
order by branch, branch_sales desc;

-- Sales trends by payment method on product wise
select payment_method, product_line, SUM(total) as payment_method_sales from amazon
group by payment_method, product_line
order by payment_method, payment_method_sales desc;

-- Sales trends by payment method 
select payment_method , sum(total) as overall_pay_sales  from amazon
group by payment_method
order by overall_pay_sales desc;

-- Customer Analysis --

-- Distinct customer segments
select distinct customer_type as customer_segment from amazon;

-- Purchase trends by customer type
select customer_type, monthname, SUM(total) AS total_sales
from amazon
group by customer_type, monthname
order by customer_type, monthname;

-- Profitability analysis by customer segment
select customer_type, sum(total) as total_sales, sum(gross_income) as total_profit
from amazon
group by customer_type
order by total_profit desc;



-- Business Question to Answers -- 

-- 1. What is the count of distinct cities in the dataset?
select count(distinct city) as distinct_cities from amazon;

-- 2. For each branch, what is the corresponding city
select branch, city from amazon group by branch, city;

-- 3. What is the count of distinct product lines in the dataset
select COUNT(distinct product_line) as distinct_product_lines from amazon;

-- 4. Which payment method occurs most frequently
select payment_method, COUNT(*) as frequency 
from amazon 
group by payment_method 
order by frequency desc limit 1 ;

-- 5. Which product line has the highest sales?
select product_line, SUM(total) as total_sales 
from amazon 
group by product_line 
order by total_sales desc limit 1;

-- 6. How much revenue is generated each month 
select monthname, sum(total) as revenue from amazon  group by monthname;

-- 7. In which month did the cost of goods(COG) sold reach its peak 
select monthname, MAX(cogs) as highest_cogs 
from amazon  
group by monthname 
order by highest_cogs desc limit 1;

-- 8. Which product line generated the highest revenue
select product_line, SUM(total) as revenue 
from amazon 
group by product_line 
order by revenue desc limit 1;

-- 9. In which city was the highest revenue recorded
select city, SUM(total) as revenue 
from amazon  
group by city 
order by revenue desc limit 1;

-- 10. Which product line incurred the highest Value Added Tax 
select product_line, SUM(VAT) as total_vat 
from amazon 
group by product_line 
order by total_vat desc limit 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
alter table amazon add column sales_quality varchar(10);
update amazon AS a
join( select invoice_id, 
           case when total > (SELECT avg(total) from amazon) then 'Good'
                else 'Bad' end as sales_quality
    from amazon
) as temp on a.invoice_id = temp.invoice_id
set a.sales_quality = temp.sales_quality;
select * from amazon;

-- 12.Identify the branch that exceeded the average number of products sold.
select branch from amazon 
group by branch having COUNT(*) > (select avg(quantity) from amazon);

-- 13. Which product line is most frequently associated with each gender
select gender, product_line, COUNT(*) as frequency 
from amazon where gender IS NOT NULL 
group by gender, product_line 
order by gender, frequency desc;

-- 14. Calculate the average rating for each product line
select product_line, avg(rating) as avg_rating 
from amazon where rating IS NOT NULL 
group by product_line;

-- 15. Count the sales occurrences for each time of day on every weekday
select dayname, timeofday, COUNT(*) as sales_occurrences from  amazon 
group by dayname, timeofday 
order by dayname, timeofday;

-- 16. Identify the customer type contributing the highest revenue
select customer_type, SUM(total) as total_revenue from amazon 
group by customer_type 
order by total_revenue desc limit 1;

-- 17. Determine the city with the highest VAT percentage
select city, avg(VAT) as avg_vat_percentage from amazon 
group by city 
order by avg_vat_percentage desc limit 1;

-- 18. Identify the customer type with the highest VAT payments
select customer_type, SUM(VAT) as total_vat_payments from amazon 
group by customer_type 
order by total_vat_payments desc limit 1;

-- 19. Count of distinct customer types in the dataset
select COUNT(distinct customer_type) as distinct_customer_types from amazon;

-- 20.  What is the count of distinct payment methods in the dataset
select COUNT(distinct payment_method) as distinct_payment_methods from amazon;

-- 21. Which customer type occurs most frequently?
select customer_type, COUNT(*) as frequency from amazon
group by  customer_type
order by frequency desc limit 1;

-- 22. Identify the customer type with the highest purchase frequency.
select customer_type, COUNT(*) as purchase_frequency from  amazon
group by customer_type
order by purchase_frequency desc limit 1;

-- 23. Determine the predominant gender among customers.
select gender, COUNT(*) as frequency from amazon
where gender IS NOT NULL
group by gender
order by frequency desc limit 1;

-- 24. Examine the distribution of genders within each branch.
select branch, gender, COUNT(*) AS frequency from amazon
where gender IS NOT NULL
group by branch, gender
order by branch, frequency;

-- 25. Identify the time of day when customers provide the most ratings.
select timeofday, COUNT(*) as rating_count from amazon
where rating IS NOT NULL
group by timeofday
order by rating_count desc limit 1;

-- 26. Determine the time of day with the highest customer ratings for each branch.
select branch, timeofday, avg(rating) as avg_rating from amazon
where rating IS NOT NULL
group by branch, timeofday
order by branch, avg_rating desc;

-- 27 Identify the day of the week with the highest average ratings.
select dayname, avg(rating) as avg_rating from amazon
where rating IS NOT NULL
group by dayname
order by avg_rating desc limit 1;

-- 28 Determine the day of the week with the highest average ratings for each branch.
select branch, dayname, avg(rating) as avg_rating 
from amazon where rating IS NOT NULL
group by branch, dayname
order by branch, avg_rating desc;














