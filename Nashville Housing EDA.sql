-- 1. Query nashville housing database LIMIT to 1000 rows
SELECT * 
FROM project_nashville_housing
LIMIT 1000

------------------------------------------------------------------------------------

-- 2. Properties per City

SELECT new_property_city,
       COUNT(new_property_city) AS properties_sold
FROM project_nashville_housing
GROUP BY new_property_city
ORDER BY properties_sold DESC

------------------------------------------------------------------------------------

-- 3.  Properties per Owner

SELECT owner_name,
       COUNT(owner_name) AS properties_owned
FROM project_nashville_housing
GROUP BY owner_name
ORDER BY properties_owned DESC

------------------------------------------------------------------------------------

-- 4.  Sold Properties per Year

SELECT EXTRACT(YEAR FROM sale_date) AS year_of_sale,
        COUNT(sale_date) AS num_of_properties_sold
FROM project_nashville_housing
GROUP BY  EXTRACT(YEAR FROM sale_date)
ORDER BY num_of_properties_sold DESC

------------------------------------------------------------------------------------

-- 5. Creating Price Categories and land use

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

SELECT category ,
       COUNT(unique_id) AS number_of_properties
FROM category_cte
GROUP BY category
ORDER BY number_of_properties DESC

------------------------------------------------------------------------------------
-- 6. Creating Price Categories and land use USING Window functions
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

-----------------------------------------------------------------------------------
-- 7.  Price Range per City

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

-----------------------------------------------------------------------------------
-- 8. Category Count per City
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


-----------------------------------------------------------------------------------
-- 9. Land usage that sells the most 

SELECT land_use, SUM(sale_price),
        ROW_NUMBER() OVER (ORDER BY SUM(sale_price) DESC) AS rank
FROM project_nashville_housing
GROUP BY land_use 

-----------------------------------------------------------------------------------
-- 10. Sales value per month per year

SELECT 
    DATE_TRUNC('month', sale_date) AS month,
    EXTRACT(year FROM sale_date) AS year,
    COUNT(*) AS total_sales,
    SUM(sale_price) AS total_sales_value
FROM 
   project_nashville_housing
GROUP BY 
    1, 2
ORDER BY 
   total_sales_value DESC;

