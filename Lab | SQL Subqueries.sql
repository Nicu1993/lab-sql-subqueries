use sakila;

-- 1. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT COUNT(*) AS Copy_Count
FROM inventory i
JOIN film f ON i.film_id = f.film_id
WHERE f.title = 'Hunchback Impossible';

-- 2. List all films whose length is longer than the average of all the films.
SELECT *
FROM film
WHERE length > (
  SELECT AVG(length)
  FROM film
);

-- 3. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT *
FROM actor
WHERE actor_id IN (
  SELECT actor_id
  FROM film_actor
  WHERE film_id = (
    SELECT film_id
    FROM film
    WHERE title = 'Alone Trip'
  )
);

-- 4. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT *
FROM film
WHERE film_id IN (
  SELECT film_id
  FROM film_category
  WHERE category_id = (
    SELECT category_id
    FROM category
    WHERE name = 'Family'
  )
);

-- 5. Get name and email from customers from Canada using subqueries. Do the same with joins. Note that to create a join, you will have to identify the correct tables with their primary keys and foreign keys, that will help you get the relevant information.

SELECT customer_id, first_name, last_name, email
FROM customer
WHERE customer_id IN (
  SELECT customer_id
  FROM address
  WHERE city_id IN (
    SELECT city_id
    FROM city
    WHERE country_id = (
      SELECT country_id
      FROM country
      WHERE country = 'Canada'
    )
  )
);

-- joins
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customer c
JOIN address a ON c.address_id = a.address_id
JOIN city ci ON a.city_id = ci.city_id
JOIN country co ON ci.country_id = co.country_id
WHERE co.country = 'Canada';

-- 6. Which are films starred by the most prolific actor? Most prolific actor is defined as the actor that has acted in the most number of films. First you will have to find the most prolific actor and then use that actor_id to find the different films that he/she starred.
SELECT f.film_id, f.title
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
WHERE fa.actor_id = (
  SELECT actor_id
  FROM (
    SELECT actor_id, COUNT(*) AS film_count
    FROM film_actor
    GROUP BY actor_id
    ORDER BY film_count DESC
    LIMIT 1
  ) AS actor_counts
);

-- 7. Films rented by most profitable customer. You can use the customer table and payment table to find the most profitable customer ie the customer that has made the largest sum of payments
SELECT f.film_id, f.title
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON i.inventory_id = r.inventory_id
JOIN payment p ON r.rental_id = p.rental_id
WHERE p.customer_id = (
  SELECT customer_id
  FROM (
    SELECT customer_id, SUM(amount) AS total_amount
    FROM payment
    GROUP BY customer_id
    ORDER BY total_amount DESC
    LIMIT 1
  ) AS customer_payments
);

-- 8. Get the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client

SELECT customer_id, SUM(amount) AS total_amount_spent
FROM payment
GROUP BY customer_id
HAVING SUM(amount) > (
  SELECT AVG(total_amount)
  FROM (
    SELECT customer_id, SUM(amount) AS total_amount
    FROM payment
    GROUP BY customer_id
  ) AS customer_payments
);