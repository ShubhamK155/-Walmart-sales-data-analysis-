create database if not exists salesDataWallmart;

use salesDataWallmart;

create table if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(30) not null,
    product_line varchar(100) not null,
    unit_price decimal(10,2) not null,
    quantity int not null,
    tax_pct float(6,4) not null,
    total decimal(12, 4) not null,
    date datetime not null,
    time time not null,
    payment varchar(15) not null,
    cogs decimal(10,2) not null,
    gross_margin_pct float(11,9),
    gross_income decimal(12, 4),
    rating float(2, 1)
);

-- --------------------------------------------- feature engineering --------------------------------------------------------

-- -----------------------------------------------   time_of_day ------------------------------------------

select time from sales;

select time, (case 
			  when `time` between "00:00:00" and "12:00:00" then "Morning"
			  when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		      else "Evening"
			  end) 
as time_of_day
from sales;

set sql_safe_updates = 0;

alter table sales
add column time_of_day varchar(50);

update sales
set time_of_day = (case 
			       when `time` between "00:00:00" and "12:00:00" then "Morning"
			       when `time` between "12:01:00" and "16:00:00" then "Afternoon"
		           else "Evening"
				   end);

-- ---------------------------------------day_name ---------------------------------------------------

select date from sales;        
select date, dayname(date) as day_name from sales;   

alter table sales
add column day_name varchar(10);

update sales
set day_name = dayname(date);

-- ---------------------------- month_name ------------------------------------------------------------

select monthname(date) as month_name from sales;

alter table sales
add column month_name varchar(15);

update sales
set month_name = monthname(date);

-- ----------------------------------------------- Generic ----------------------------------------------------------------------------------------

-- --------------------------------- How many unique cities does the data have ? ----------------------

select distinct city as unique_cities from sales;

-- ----------------------------------------In which city is each branch ?-----------------------------

select distinct branch from sales;

select distinct city ,branch from sales;

-- ------------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------- Product -----------------------------------------------------------------

-- ------------------------How many unique product lines does the data have?-----------------------------------------------

select count(distinct product_line) as unique_product_lines from sales;

-- --------------------------------------What is the most common payment method?----------------------------------------

select count(payment_method), payment_method as count_of_payment_method
from sales
group by payment_method 
order by count_of_payment_method desc;

-- --------------------------------What is the most selling product line?---------------------------------------------------------------

select product_line, count(product_line) as most_selling_product_line 
from sales
group by product_line
order by most_selling_product_line desc;

-- --------------------------------------What is the total revenue by month?--------------------------------------

select month_name , sum(total) as total_revenue_by_month from sales
group by month_name
order by total_revenue_by_month desc;

-- ----------------------------------------What month had the largest COGS?--------------------------------

select month_name, sum(cogs) as largest_cogs_month from sales
group by month_name
order by largest_cogs_month desc;

-- ----------------------------What product line had the largest revenue?------------------------------------

select product_line, sum(total) as largest_revenue_product_line
from sales
group by product_line
order by largest_revenue_product_line desc; 

-- -----------------------------What is the city with the largest revenue?-------------------------

select city, branch, sum(total) as largest_revenue
from sales
group by city, branch
order by largest_revenue desc;

-- ---------------------------------------------What product line had the largest VAT?---------------------------

select product_line , avg(VAT) as average_VAT 
from sales
group by product_line
order by average_VAT desc;

-- -----Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales---------

select  avg(qauntity) as avg_qnty from sales;

select product_line,
	    case
		when avg(qauntity) > 6 then "Good"
        else "Bad"
        end as remark
from sales
group by product_line;

-- --------------------Which branch sold more products than average product sold?--------------------------------

select branch, sum(qauntity) as average_product_sold from sales
group by branch
having sum(qauntity)>(select avg(qauntity) from sales);

-- ----------------------------------------What is the most common product line by gender?--------------------------------------------

select gender, product_line, count(gender) as product_line_by_gender from sales
group by gender, product_line
order by product_line_by_gender desc;

-- ------------------------------------------What is the average rating of each product line?--------------------------------------------

select product_line, round(avg(rating),2) as avg_rating from sales
group by product_line
order by avg_rating desc;

-- ----------------------------------------sales----------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------------------------

-- ----------------Number of sales made in each time of the day per weekday-------------------------------------------------------

select time_of_day, count(*) as total_sales from sales
where day_name = "Sunday"
group by time_of_day
order by total_sales desc;

-- -------------------Which of the customer types brings the most revenue?----------------

select customer_type, sum(total) as total_revenue_by_customer_type from sales
group by customer_type
order by  total_revenue_by_customer_type desc;

-- --------------------------------------Which city has the largest tax percent/ VAT (Value Added Tax)?-------------

select city, avg(VAT) as tax_by_city from sales
group by city
order by tax_by_city desc;

-- --------------------------------------Which customer type pays the most in VAT?-----------------------------
select customer_type, avg(VAT) as tax_by_customer_type from sales
group by customer_type
order by tax_by_customer_type desc;

-- -----------------------------------------------Customer----------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------------------

-- ---------------------------------How many unique customer types does the data have?-------------------------------------

select distinct customer_type from sales;

-- ---------------------------------How many unique payment methods does the data have?------------------------------------

select distinct payment_method from sales;

-- ---------------------------------What is the most common customer type?------------------------------------------------

select customer_type,count(*) as most_common_cust_type from sales
group by customer_type
order by most_common_cust_type desc;

-- ----------------------Which customer type buys the most?--------------------------------------------------------

select customer_type, count(*) as cust_type_count from sales
group by customer_type;

-- ------------------------------------What is the gender of most of the customers?----------------------------
select gender,count(gender) as common_gender from sales
group by gender
order by common_gender desc;

-- -----------------------------------------------What is the gender distribution per branch?------------------

select gender, count(*) as gender_count from sales
where branch = "A"
group by gender
order by gender_count desc;

-- ----------------------Which time of the day do customers give most ratings?------------------------------

select time_of_day, avg(rating) as avg_rating from sales
group by time_of_day
order by avg_rating desc;

-- ----------------------------Which time of the day do customers give most ratings per branch?---------------

select time_of_day, avg(rating) as avg_rating from sales
where branch = "a"
group by time_of_day
order by avg_rating desc;

-- ---------------------------Which day fo the week has the best avg ratings?----------------------------------

select day_name, avg(rating)  as avg_rating_day from sales
group by day_name
order by avg_rating_day desc;

-- -----------------------------Which day of the week has the best average ratings per branch?--------------

select day_name, avg(rating)  as avg_rating_day from sales
where branch = "a"
group by day_name
order by avg_rating_day desc;



















