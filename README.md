# Nashville-Housing-Analysis

##Nashville Housing Exploratory Data Analysis

These SQL queries involve analyzing the cleaned data in the Nashville Housing dataset for various business insights hidden in it:

#####Properties per City: 

```
SELECT new_property_city,
       COUNT(new_property_city) AS properties_sold
FROM project_nashville_housing
GROUP BY new_property_city
ORDER BY properties_sold DESC
```
Counts the number of properties sold per city and presents the data in descending order of properties sold.

<img width="523" alt="Screenshot 2024-09-16 at 17 08 11" src="https://github.com/user-attachments/assets/72a52fa3-5dd5-48c7-be11-2b8a5dab2a82">

 
#####Properties per Owner
```
SELECT owner_name,
       COUNT(owner_name) AS properties_owned
FROM project_nashville_housing
GROUP BY owner_name
ORDER BY properties_owned DESC
```
Counts the number of properties each owns, excluding cases with null owner names.
<img width="523" alt="Screenshot 2024-09-16 at 17 14 56" src="https://github.com/user-attachments/assets/4e3cbc67-53f1-422c-b6cb-8f68fd5e6809">

#####Sold Properties per Year
```
SELECT EXTRACT(YEAR FROM sale_date_only) AS year_of_sale,
        COUNT(sale_date_only) AS num_of_properties_sold
FROM project_nashville_housing
GROUP BY  EXTRACT(YEAR FROM sale_date_only)
ORDER BY num_of_properties_sold DESC
```
<img width="523" alt="Screenshot 2024-09-16 at 17 28 29" src="https://github.com/user-attachments/assets/0372bdda-ebda-4162-9575-cc6ffc67bf64">

#####Creating Price Categories and land use
```
WITH category_cte AS (
SELECT 
      *, 
      CASE 
          WHEN sale_price < 1000000 THEN 'Cheap'
          WHEN sale_price BETWEEN 100000 AND 1000000 THEN 'Medium'
          ELSE 'Expensive'
      END AS category
FROM project_nashville_housing 
)

SELECT category,
       COUNT(unique_id) AS number_of_properties
FROM category_cte
GROUP BY category
ORDER BY number_of_properties DESC
```
<img width="493" alt="Screenshot 2024-09-17 at 16 05 55" src="https://github.com/user-attachments/assets/543307fc-7708-454c-9ba2-11a2ba0ac5f1">

#####Creating Price Categories and land use USING Window functions
```
    SELECT 
    unique_id, 
    land_use,
    sale_price,
    CASE 
        WHEN sale_price < 100000 THEN 'Cheap'
        WHEN sale_price BETWEEN 100000 AND 1000000 THEN 'Medium'
        ELSE 'Expensive'
    END AS category,
    ROW_NUMBER() OVER (PARTITION BY land_use ORDER BY sale_price DESC) AS land_use_rank
FROM project_nashville_housing
ORDER BY land_use, land_use_rank;
```
<img width="843" alt="Screenshot 2024-09-16 at 19 30 18" src="https://github.com/user-attachments/assets/cb63c38c-56b5-4b2c-a81d-7a05b6f8d825">

#####Price Range per City

```
WITH a AS (
SELECT  *,
        CASE 
          WHEN sale_price < 1000000 THEN 'Cheap'
          WHEN sale_price BETWEEN 100000 AND 1000000 THEN 'Medium'
          ELSE 'Expensive'
        END AS category
FROM project_nashville_housing
),
    b AS 
(
SELECT  category,
        new_property_city,
        COUNT(unique_id) AS range 
FROM a 
GROUP BY category,
         new_property_city
)

SELECT new_property_city,
       category,
       SUM(range)
FROM b 
GROUP BY new_property_city, 
         category
ORDER BY SUM(range) DESC
```
<img width="641" alt="Screenshot 2024-09-16 at 23 05 03" src="https://github.com/user-attachments/assets/782468ad-9a48-444b-b02b-3429b25dd7c9">

#####Category Count per City
```
WITH price_category AS 
(
	SELECT
		*, 
		CASE
			WHEN sale_price <= 100000 THEN 'Cheap'
			WHEN sale_price BETWEEN 100000 AND 1000000 THEN 'Average'
			ELSE 'Expensive'
		END AS category
	FROM project_nashville_housing
),
category_city AS
(
	SELECT
		category, 
		new_property_city,
		COUNT(unique_id) as range
	FROM price_category
	GROUP BY category, new_property_city
),
city_name AS
(
	SELECT DISTINCT new_property_city
	FROM price_category
)
SELECT
	c.new_property_city,
	COALESCE(Cheap.range, 0) AS cheap_properties,
	COALESCE(Average.range, 0) AS average_properties,
	COALESCE(Expensive.range, 0) AS expensive_properties
FROM city_name c
LEFT JOIN category_city AS Cheap
	ON c.new_property_city = Cheap.new_property_city
	AND Cheap.category = 'Cheap'
LEFT JOIN category_city AS Average
	ON c.new_property_city = Average.new_property_city
	AND Average.category = 'Average'
LEFT JOIN category_city AS Expensive
	ON c.new_property_city = Expensive.new_property_city
	AND Expensive.category = 'Expensive'
ORDER BY c.new_property_city;
```
<img width="761" alt="Screenshot 2024-09-17 at 00 41 50" src="https://github.com/user-attachments/assets/f591c57c-eae8-42b2-9b2c-e86ccd2cb978">

#####Land usage that sells the most 
```
SELECT land_use, SUM(sale_price),
        ROW_NUMBER() OVER (ORDER BY SUM(sale_price) DESC) AS rank
FROM project_nashville_housing
GROUP BY land_use 
```
<img width="495" alt="Screenshot 2024-09-17 at 00 16 32" src="https://github.com/user-attachments/assets/c6eefcb1-b619-4508-b5bc-ae25be121579">

#####Sales value per month per year
```
SELECT 
    DATE_TRUNC('month', sale_date_only) AS month,
    EXTRACT(year FROM sale_date_only) AS year,
    COUNT(*) AS total_sales,
    SUM(sale_price) AS total_sales_value
FROM 
   project_nashville_housing
GROUP BY 
    1, 2
ORDER BY 
   total_sales_value DESC;
```
<img width="645" alt="Screenshot 2024-09-17 at 00 35 14" src="https://github.com/user-attachments/assets/37816258-d84c-492c-84cd-ce5b5ba5a5e6">

##Insights 
The processed and modified **Nashville Housing** dataset can be leveraged to extract valuable insights into various aspects of the **real estate market.** These insights encompass **trends in property sales, price segmentation, ownership patterns, and other significant factors. By sorting properties into different price ranges, analyzing property sales trends over time, and examining the impact of ownership changes, these examples offer a deeper understanding of the dynamics within the Nashville housing market.** Through careful data manipulation and analysis, we can derive key insights such as:

- **Property Sales Trends**: Volume of property sales has steadily inreased over time with a sudden bump in 2015 shedding light on market activity which could be due to increase in disposable income and a steady movement in interest rates by the Fed during that time.
Property business seems does not have observable seasonal variations. The period 2010 to 2012 showed a bit of slow numbers which could be due to the 2008-2009 economic slump 
  
- **Price Segmentation**: Categorizing properties into groups such as 'Affordable,' 'Mid-Range,' and 'Luxury' based on their sale prices. Majority of condos are not cheap and the most expensive land use at $12.5m being a church 

- **Ownership Patterns**: Nashville has one of the more expensive housing with a median income. Most properties is in the hands of LCCs than individuals

- **Market Segmentation**: Single-family homes do make a greater majority of home sales, a good opportunity for any developer and real estate investor

These examples lay the groundwork for real estate professionals, policymakers, and investors to make well-informed decisions based on a comprehensive understanding of the Nashville housing market. The insights derived can guide strategic investments, and urban planning, and assist homebuyers in identifying opportunities in specific areas. By harnessing the power of data, we can gain a deeper understanding of Nashville’s evolving real estate landscape.
