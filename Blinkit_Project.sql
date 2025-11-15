
DROP TABLE
if exists blinkit;
CREATE TABLE blinkit(

Item_Fat_Content varchar(25),
Item_Identifier varchar(15),
Item_Type varchar(50),
Outlet_Establishment_Year int,
Outlet_Identifier varchar(15),
Outlet_Location_Type varchar(10),
Outlet_Size varchar(15),
Outlet_Type varchar(40),
Item_Visibility  float,
Item_Weight float,
Total_Sales DECIMAL(12,4),
Rating DECIMAL(3,1)
);

SELECT * from 	blinkit;

SELECT count(*) from blinkit;	

UPDATE blinkit
SET Item_Fat_Content ='Low Fat'
WHERE Item_Fat_Content in ('LF','lowfat','Lowfat','low fat')

update blinkit
set item_fat_content = 'Regular'
where blinkit.item_fat_content in ('regular','reg','RG')

select distinct(item_fat_content) from blinkit

select cast(sum(Total_Sales)/1000000 as DECIMAL(10,2)) as Total_sales_million
from blinkit

select cast(avg(blinkit.total_sales)as decimal(10,0)) as AVG_sales
from blinkit

select cast(avg(Rating)as decimal(10,0)) as AVG_Rating
from blinkit

select 
blinkit.item_fat_content, 
CAST(sum(blinkit.total_sales) as decimal(10,2)) as Tota_sales
from blinkit
group by 1
ORDER by 2 DESC

--- Fat Content by Outlet for Total Sales

SELECT Outlet_Location_Type,
sum(total_sales) FILTER (where item_fat_content= 'Low Fat') as Low_Fat,
sum	(total_sales) FILTER(WHERE blinkit.item_fat_content = 'Regular') as Regular_Fat
FROM blinkit
GROUP by 1
ORDER by Outlet_Location_Type DESC

--- Total Sales by Outlet Establishment

SELECT Outlet_Establishment_Year,
cast(sum(total_sales) as decimal(10,2)) as Total_sales
FROM blinkit
GROUP by 1
ORDER by 1 desc

---- Percentage of Sales by Outlet Size
SELECT blinkit.outlet_size,
round(sum(blinkit.total_sales),2) as Total_sales,
round(100.0*sum(blinkit.total_sales)/sum(sum(total_sales)) OVER(),2) as Sales_percentage
from blinkit
GROUP by 1
ORDER by 1

--- Sales by Outlet Location


SELECT 
sum(total_sales) as Total_sales,
outlet_location_type
from blinkit
GROUP by 2
ORDER by 2

-- All Metrics by Outlet Type:

SELECT outlet_type,
cast(sum(blinkit.total_sales)as decimal(10,2)) as Total_sales,
cast(avg(blinkit.total_sales)as decimal(10,0)) as Total_avg,
count(*) as No_of_items,
cast(avg(Rating)as decimal(10,0)) as Avg_Rating,
cast(avg(blinkit.item_visibility) as decimal(10,2)) as Avg_item_visibility,
cast(avg(blinkit.item_weight) as decimal(10,0)) as Avg_weight
FROM blinkit
GROUP by outlet_type
ORDER by total_sales DESC

-- Find the Top 5 Highest-Selling Items by Total Sales

SELECT blinkit.item_type,
cast(sum(total_sales)as decimal(10,2)) as Total
from blinkit
GROUP by 1
order by 2 DESC
LIMIT 5

--- Percentage Contribution of Each Outlet Type to Total Sales

SELECT outlet_type,
cast(sum(total_sales) *100.0 / sum(sum(total_sales)) OVER() AS decimal(10,2)) as sales_Percentage
from blinkit
GROUP by 1
ORDER by sales_Percentage DESC

-- Average Sales per Item Fat Content across Different Outlet Sizes

SELECT distinct item_fat_content, outlet_size,
cast(avg(total_sales) as decimal(10,0)) as AVG_sales
from blinkit
group by 1,2
ORDER by outlet_size

---  Year-on-Year Sales Trend for Each Outlet

SELECT Outlet_Identifier ,Outlet_Establishment_Year ,
cast(sum(total_sales) as decimal(10,2)) as Total_sales
from blinkit
GROUP by Outlet_Identifier ,Outlet_Establishment_Year 
ORDER by Outlet_Establishment_Year,total_sales desc	

--- Find the Most Popular Item Type in Each Outlet Location Type

WITH ranked_sales as
(
SELECT 
Item_Type ,Outlet_Location_Type ,
cast(sum(total_sales)as decimal(10,2)) as Total_sales,
rank() over(partition by Outlet_Location_Type
ORDER by sum(total_sales) DESC) as rnk
FROM blinkit	
group by Item_Type,Outlet_Location_Type
)
SELECT Item_Type,Outlet_Location_Type,total_sales
from ranked_sales
WHERE rnk =1

--- Rank Outlets by Performance Using RANK()

select outlet_identifier,
sum(total_sales) as Total_sales,
rank() over(order by sum(total_sales) DESC) as sales_rank
from blinkit
group by outlet_identifier

---- Correlation Check: Do Heavier Items Sell More?

select 
	case 
		when Item_Weight >10 THEN 'Light'
		when Item_Weight BETWEEN 10 and 20 then 'Medium'
		ELSE 'Heavy'
	END as Weight_category,
	avg(total_sales) as Avg_sales
FROM blinkit
group by Weight_category
ORDER by Avg_sales desc

--- Calculate Cumulative Sales per Outlet Over Time

SELECT outlet_identifier,
Outlet_Establishment_Year ,
sum(total_sales) as Yearly_sales,
sum(sum(total_sales)) OVER( partition by outlet_identifier order by Outlet_Establishment_Year ) as Cumulative_Sale
FROM blinkit
group by 1 ,2
order by 1,2 desc                  

-- Calculate Cumulative Sales per Outlet

SELECT 
    Outlet_Identifier,
    Item_Identifier,
    SUM(Total_Sales) AS Item_Sales,
    SUM(SUM(Total_Sales)) OVER(
        PARTITION BY Outlet_Identifier 
        ORDER BY Item_Identifier
    ) AS Cumulative_Sales
FROM blinkit
GROUP BY Outlet_Identifier, Item_Identifier
ORDER BY Outlet_Identifier, Item_Identifier;

-- Identify Items with Visibility but Low Sales (High Marketing, Poor Sales)

SELECT
Item_Identifier,Item_type,
cast(avg(Item_visibility) as decimal(10,2)) as Avg_visibility,
avg(total_sales) as Avg_sales
from blinkit
group by 1,2
HAVING avg(Item_visibility)>0.05 and avg(total_sales) <100

--- Outlet Size vs Average Customer Rating

SELECT * from blinkit

SELECT outlet_size,
avg(Rating ) as avg_rating
from blinkit
GROUP by 1

-- Which products drive the most revenue?

SELECT Item_Type ,Item_Identifier ,
round(sum(total_sales),2) as Total_revenue,
rank() OVER (order by sum(total_sales) desc) as Revenue_rank
from blinkit
group by 1,2

-- Which outlet type contributes the most to overall sales?

SELECT 
outlet_type,
round(sum(total_sales),2) as total_sales,
round(sum(total_sales)* 100 /sum(sum(total_sales)) over(),2) as sales_percentage
FROM blinkit
group by 1
order by total_sales desc

--- Are customers preferring Low Fat or Regular items?

SELECT item_fat_content,
round(avg(total_sales),2) as avg_sales_per_item,
count(*) as Items_sold
FROM blinkit
group by item_fat_content
ORDER by avg_sales_per_item DESC


-- Which location tier has the best revenue potential?

SELECT 
blinkit.outlet_type,
round(sum(total_sales),2) as Total_sale,
round(avg(total_sales),2) as Avg_sales
from blinkit
GROUP by 1
ORDER by Total_sale desc


--- Which products have high visibility but low sales?

SELECT 
item_type,
item_identifier,
round(avg(Item_Visibility):: numeric,4) AS Avg_Visibility,
round(avg(total_sales),2) as avg_sales
from blinkit
GROUP by item_type,item_identifier
HAVING avg(Item_Visibility)>0.05 and avg(total_sales) <100
ORDER by Avg_Visibility DESC


-- Do older outlets perform worse than newer ones?

SELECT 
Outlet_Identifier,
Outlet_Establishment_Year,
round(sum(total_sales)) as Total_sales,
rank() over(order by sum(total_sales) DESC) as Performance_rank
from blinkit
GROUP by  1,2
ORDER by Outlet_Establishment_Year ASC

--- Best-performing product categories in each outlet type

WITH cat_rank as 
(
SELECT Item_Type , Outlet_Type ,
round(sum(total_sales),2)as Total_sales,
rank()OVER(partition by Outlet_Type order by sum(total_sales) desc ) as category_rank
from blinkit
GROUP by 1,2
)

SELECT * from cat_rank
WHERE category_rank =1

-- Which outlet size gives best balance of sales & ratings?

select Outlet_Size ,round(avg(Rating),2) as AVG_rating,
round(avg(total_sales),2) as Total_sales
from blinkit
group by Outlet_Size DESC

-- Year-on-Year Growth by Outlet Type

SELECT blinkit.outlet_type,
extract(year from current_date) - Outlet_Establishment_Year as years_active,
round(sum(total_sales)/nullif(EXTRACT(year from current_date)-Outlet_Establishment_Year,0),2) as AVG_Annual_sales
from blinkit
group by outlet_type,Outlet_Establishment_Year
ORDER by AVG_Annual_sales desc

--- Product Visibility vs. Sales Effectiveness

SELECT  item_type,
round(avg(item_visibility)::numeric, 2) as AVG_item_visibility,
round(avg(total_sales),2) as AVG_sales,
corr(item_visibility,total_sales) as Visibility_Sales_Correlation
from blinkit
group by item_type
ORDer by Visibility_Sales_Correlation desc




SELECT * from blinkit













































































