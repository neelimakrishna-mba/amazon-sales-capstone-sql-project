#Data Wrangling

Create database amazon_sales;

use amazon_sales;

create table sales (
invoice_id varchar(30) not null,
branch VARCHAR(5) not null,
city VARCHAR(30) not null,
customer_type VARCHAR(30) not null,
gender VARCHAR(10) not null,
product_line VARCHAR(100) not null,
unit_price DECIMAL(10, 2) not null,
quantity INT not null,
VAT FLOAT not null,
total DECIMAL(10, 2) not null,
date DATE not null,
time time not null,
payment_method varchar(30) not null,
cogs DECIMAL(10, 2) not null,
gross_margin_percentage FLOAT not null,
gross_income DECIMAL(10, 2) not null,
rating FLOAT not null) ;
select * from sales;

# Feature Engeneering

Alter table sales
add time_of_day varchar(10);

set sql_safe_updates = 0;

update sales
set time_of_day = 
case when hour(time) between 0 and 11 then "Morning"
when hour(time) between 11 and 16 then "Afternoon"
else "Evening" End;

Alter table sales
add day_name varchar(10);

update sales
set day_name = dayname(date);

Alter table sales
add month_name varchar(10);

update sales
set month_name = monthname(date);

select * from sales;

#Exploratory Data Analysis

#1.What is the count of distinct cities in the dataset?
select count(distinct city) from sales;

#2.For each branch, what is the corresponding city?
select distinct branch,city from sales;

#3.What is the count of distinct product lines in the dataset?
select count(distinct product_line) from sales;

#4.Which payment method occurs most frequently?
select payment_method, count(payment_method) as times_of_occurance from sales
group by payment_method
order by count(payment_method) desc
limit 1;

#5.Which product line has the highest sales?
# if it is amount
select product_line, sum(total) as Total_sales from sales 
group by product_line
order by sum(total)  desc
limit 1 ;
# if it is quantity
select product_line, sum(quantity) as Total_sales from sales 
group by product_line
order by sum(quantity)  desc
limit 1 ;

#6.How much revenue is generated each month?
select month_name ,sum(total) as Total_Revenue
from sales
group by month_name;

#7.In which month did the cost of goods sold reach its peak?
select month_name, sum(cogs) as Total_Cost_Of_Goods
from sales
group by month_name
order by sum(cogs) desc
limit 1 ;

#8.Which product line generated the highest revenue?
select product_line,sum(total) as total_revenue
from sales
group by product_line
order by sum(total) desc
limit 1;

#9.In which city was the highest revenue recorded?
select city,sum(total) as total_revenue
from sales
group by city
order by sum(total) desc;
limit 1;

#10.Which product line incurred the highest Value Added Tax?
select product_line, round(sum(VAT),2) as total_value_added_tax
from sales
group by product_line
order by sum(VAT) DESC
limit 1;

#11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
SELECT product_line,
SUM(total) AS total_sales,
CASE 
WHEN SUM(total) > (SELECT AVG(total_sales)
FROM (SELECT SUM(total) AS total_sales FROM sales
GROUP BY product_line) AS avg_table) THEN 'Good' ELSE 'Bad' END AS performance
FROM sales
GROUP BY product_line;

#12.Identify the branch that exceeded the average number of products sold.
select branch,sum(quantity) as total_quantity
from sales group by branch having sum(quantity) > (select avg(total_quantity) from 
(select sum(quantity) as total_quantity from sales group by branch) as branch_totals);

#13.Which product line is most frequently associated with each gender?
WITH gender_product_counts AS (SELECT 
gender,
product_line,
COUNT(*) AS purchase_count,
RANK() OVER (PARTITION BY gender ORDER BY COUNT(*) DESC) AS rnk
FROM sales
GROUP BY gender, product_line)
SELECT gender, product_line, purchase_count
FROM gender_product_counts
WHERE rnk = 1;

#14.Calculate the average rating for each product line.
select product_line,round(avg(rating),2) as average_rating
from sales
group by product_line
order by avg(Rating) desc;

#15.Count the sales occurrences for each time of day on every weekday.
select day_name,time_of_day,count(*) as sales_occurrences
from sales 
group by day_name,time_of_day
ORDER BY FIELD(day_name, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'),
FIELD(time_of_day, 'Morning', 'Afternoon', 'Evening');

#16.Identify the customer type contributing the highest revenue.
select customer_type,sum(total) as total_revenue,
(sum(total)*100/(select sum(total) from sales)) as percentage_sales
from sales
group by customer_type
order by sum(total) desc
limit 1 ;

#17.Determine the city with the highest VAT percentage.
select city,round(((VAT/cogs)*100),2) as vat_percentage
from sales
order by round(((VAT/cogs)*100),2) desc
limit 1;

#18.Identify the customer type with the highest VAT payments.
select customer_type,round(sum(VAT),2) as total_Vat_payments
from sales
group by customer_type
order by sum(VAT) desc
limit 1;

#19.What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as distinct_customer_types
from sales;

#20.What is the count of distinct payment methods in the dataset?
select count(distinct payment_method) as distinct_payment_method
from sales;

#21.Which customer type occurs most frequently?
select customer_type,count(customer_type) as number_of_occurances
from sales
group by customer_type
order by count(customer_type) desc
limit 1;

#22.Identify the customer type with the highest purchase frequency.
select customer_type,count(customer_type) as purchase_frequency
from sales
group by customer_type
order by count(customer_type) desc
limit 1;

#23.Determine the predominant gender among customers.
select gender,count(gender) as gender_count ,sum(total)  as total_sales,
Round(sum(total)*100/(select sum(total) from sales),2) as percentage_sales
from sales
group by gender
order by count(gender) desc
limit 1;

#24.Examine the distribution of genders within each branch.
select branch,gender,count(gender) as distribution_of_gender
from sales
group by branch,gender
order by field(branch,"A","B","C"),field(gender,"Male","Female");

#25.Identify the time of day when customers provide the most ratings.
select time_of_day,count(rating) as number_of_ratings
from sales
group by time_of_day
order by count(rating) desc
limit 1;

#26.Determine the time of day with the highest customer ratings for each branch.
with branch_time_of_day as (
select branch,time_of_day,count(rating) as number_of_ratings,
rank() over(partition by branch order by count(rating) desc) as rnk
from sales
group by branch,time_of_day)
select branch,time_of_day,number_of_ratings
from branch_time_of_day
where rnk = 1;

#27.Identify the day of the week with the highest average ratings.
select day_name,round(avg(rating),2) as highest_average_rating
from sales
group by day_name
order by avg(rating) desc
limit 1;



#28.Determine the day of the week with the highest average ratings for each branch.
with high_avg_rating as(
select branch,day_name,round(avg(rating),2) as highest_average_rating,
rank() over(partition by branch order by avg(rating) desc) as rnk
from sales
group by branch,day_name)
select branch,day_name,highest_average_rating
from high_avg_rating
where rnk = 1;

# 1. Product Analysis
#Highest Revenue Product Line: Food and Beverages – ₹56,144.96
#Lowest Revenue Product Line: Health and Beauty – ₹49,193.84
#Highest Quantity Sold: Electronic Accessories – 971 units
#Lowest Quantity Sold: Health and Beauty – 851 units
#Most Popular Among Females: Fashion Accessories (96 purchases)
#Most Popular Among Males: Health and Beauty (88 purchases)
#Highest Rated Product Line: Food and Beverages – 7.11

#Insights:
#Food and Beverages perform best overall in terms of both revenue and customer satisfaction.
#Electronic Accessories lead in volume, showing strong demand.
#Health and Beauty lags in both revenue and quantity sold — a potential area for improvement.
#Gender-based preferences suggest targeted marketing can be effective.

#2. Sales Analysis
#Highest Revenue Month: January – ₹116,292.11
#Peak Sales Day & Time: Saturday Afternoon – 69 sales
#City with Highest Revenue: Naypyitaw – ₹110,568.86
#Branch with Highest Quantity Sold: Yangon – 1,859 units

#Insights:
#January might align with seasonal or promotional boosts (e.g., New Year sales).
#Weekends (especially Saturday afternoons) are peak times — a good opportunity for timed promotions.
#Naypyitaw leads in revenue, but Yangon handles more volume — different dynamics to explore.

# 3. Customer Analysis
#Predominant Customer Type: Member – 50.8% of revenue (₹164,223.81)
#Predominant Gender: Female – 51.9% of customers

#Insights:
#Members not only shop more frequently but also contribute more to revenue — suggesting loyalty programs are working.
#Female customers form the majority — brands and campaigns can be tailored accordingly.

# Key Takeaways:
#Food and Beverages is a high-performing product line in both sales and customer satisfaction.
#Electronic Accessories are in demand by quantity, indicating opportunities for bundling or upselling.
#Health and Beauty needs focused marketing or product repositioning.
#Peak sales time is Saturday afternoon — ideal for running flash sales or targeted ads.
#Member customers drive the majority of revenue — strengthening loyalty programs could yield further growth.
#Female shoppers dominate — product positioning and promotions can reflect this demographic trend.

# Recommendations:
#Improve performance of Health and Beauty via offers, rebranding, or customer feedback analysis.
#Leverage Electronic Accessories’ popularity with bundle deals and accessory add-ons.
#Run targeted weekend afternoon campaigns or flash sales to capture peak traffic.
#Focus marketing and loyalty rewards toward Member customers to increase retention and referrals.
#Design marketing creatives and product offerings with female preferences in mind for better conversion.