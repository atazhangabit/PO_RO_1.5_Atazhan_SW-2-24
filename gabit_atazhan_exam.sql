SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- Task 1
SELECT
    title,
    rating,
    length,
    rental_rate
FROM film
WHERE rating IN ('PG', 'PG-13')
  AND length > 100
ORDER BY title;


-- Task 2
SELECT
    c.first_name,
    c.last_name,
    c.email,
    co.country
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada'
ORDER BY c.last_name;


-- Task 3
SELECT
    cat.name AS category_name,
    COUNT(f.film_id) AS film_count
FROM category cat
JOIN film_category fc ON cat.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY cat.name
ORDER BY film_count DESC;


-- Task 4
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_payment
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING SUM(p.amount) > 150
ORDER BY total_payment DESC;