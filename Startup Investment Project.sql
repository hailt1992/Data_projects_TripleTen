/* Create a table that has the highest and lowest amount of money raised for each date in the funding_round table. */

WITH selected_fund AS (SELECT funded_at,
       MIN(raised_amount) AS lowest_amount,
        MAX(raised_amount) AS highest_amount
FROM funding_round
GROUP BY funded_at)
SELECT *
FROM selected_fund
WHERE lowest_amount > 0 AND lowest_amount <> highest_amount;

/* Create a new field with categories: high_activity, middle_activity and low_activity
Calculate the average number of funding rounds the fund participated in. Round it to the nearest whole number. Print the categories and the average number of funding rounds.*/

WITH fund_performance AS 
    (SELECT *,
       CASE
           WHEN invested_companies>=100 THEN 'high_activity'
           WHEN invested_companies>=20 THEN 'middle_activity'
           ELSE 'low_activity'
       END AS activity
FROM fund)
SELECT activity, 
      ROUND(AVG(investment_rounds)) AS avg_number_of_funding_round
FROM fund_performance
GROUP BY activity
ORDER BY avg_number_of_funding_round;

/* Make a list with the names of companies that closed down and had only one funding round while they existed. 
Calculate the number of degree type for each employee from the list of found companies.*/

SELECT p.id,
       COUNT(e.degree_type) AS total_degree_type
FROM people AS p 
JOIN education AS e ON e.person_id = p.id
WHERE p.company_id IN     
    (SELECT c.id
    FROM company AS c 
    JOIN funding_round AS f ON f.company_id = c.id  
    WHERE (f.is_first_round = 1 AND f.is_last_round = 1)
        AND c.status = 'closed')
GROUP BY p.id;

/* Export a table with the ten countries that have the most active venture funds. You can identify the level of activity by the average number of companies the country’s venture funds invest in. 

For each country, calculate the lowest, highest, and average number of companies that received investments from funds founded between 2010 and 2012. */

SELECT country_code, 
        MIN(invested_companies) AS min_invested_company,
        MAX(invested_companies) AS max_invested_company,
        AVG(invested_companies) AS avg_invested_company
FROM fund 
WHERE EXTRACT (YEAR FROM founded_at :: date ) >= 2010
    AND EXTRACT (YEAR FROM founded_at :: date ) <= 2012
GROUP BY country_code  
HAVING MIN(invested_companies) > 0
ORDER BY avg_invested_company DESC,
        country_code
LIMIT 10;

/* Write a similar query: print the average number of degree types (all, not just the unique ones) that employees of Facebook graduated with.*/

WITH facebook_employee AS
    (SELECT p.id, p.company_id, COUNT(e.degree_type) AS total_degree_type
    FROM education AS e 
    JOIN people AS p ON e.person_id = p.id
    WHERE p.company_id IN (SELECT id
                FROM company 
                WHERE name = 'Facebook')
    GROUP BY p.id, p.company_id)
SELECT AVG(total_degree_type)
FROM facebook_employee;

/*Export a table containing the following fields:
Name of the buying company
Transaction amount
Name of the acquired company
Amount of money invested in the acquired company
Percentage (rounded to the nearest whole number) showing how much the acquisition amount exceeded the amount of money invested in the company*/

SELECT  c.name AS buying_company, 
        a.price_amount AS transaction_amount,
        c1.name AS acquired_company,
        c1.funding_total AS invested_amount,
        ROUND(a.price_amount/c1.funding_total) AS percentage
FROM acquisition AS a
LEFT JOIN company AS c ON a.acquiring_company_id = c.id 
LEFT JOIN company AS c1 ON a.acquired_company_id = c1.id
WHERE a.price_amount > 0 AND c1.funding_total > 0
ORDER BY transaction_amount DESC, acquired_company
LIMIT 10;

/* Export a table with the names of companies from the social category that raised money between 2010 and 2013. Print the number of the month when the funding round took place.*/

SELECT  name, 
        EXTRACT(MONTH FROM fr.funded_at) AS funded_month
FROM company AS c
JOIN funding_round AS fr ON c.id = fr.company_id
WHERE c.category_code = 'social' 
AND (EXTRACT(YEAR FROM fr.funded_at) >= 2010 AND EXTRACT(YEAR FROM fr.funded_at) <= 2013)
AND fr.raised_amount <> 0;

/* Select the data for each month from 2010 to 2013 when the funding rounds took place. Group the data by month number and create a table with the following fields:
- The month when the funding rounds took place
- The number of unique funds from the USA that invested money this month
- The number of companies that were bought this month
- The total sum of transactions for acquisitions this month */

WITH funding_round_month AS 
    (SELECT EXTRACT(MONTH FROM fr.funded_at) AS month,
            COUNT(DISTINCT f.id) AS count_of_fund
    FROM funding_round fr
    LEFT JOIN investment i ON i.funding_round_id = fr.id
    LEFT JOIN fund f ON i.fund_id = f.id 
    WHERE (EXTRACT(YEAR FROM fr.funded_at) BETWEEN 2010 AND 2013)
     AND f.country_code = 'USA'
    GROUP BY month), 
month_of_acquired AS
    (SELECT EXTRACT(MONTH FROM acquired_at) AS month,
            COUNT(acquired_company_id) AS total_companies,
            SUM(price_amount) AS total
    FROM acquisition 
    WHERE (EXTRACT(YEAR FROM acquired_at) BETWEEN 2010 AND 2013)
    GROUP BY month)
SELECT  funding_round_month.month,
        funding_round_month.count_of_fund,
        month_of_acquired.total_companies,
        month_of_acquired.total
FROM funding_round_month
JOIN month_of_acquired ON funding_round_month.month = month_of_acquired.month;

