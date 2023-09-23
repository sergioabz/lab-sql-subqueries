-- 1. Determine the number of copies of the film "Hunchback Impossible" that exist in the inventory system.
USE sakila;
SELECT f.title, count(i.film_id) FROM sakila.inventory as i
JOIN film as f
ON i.film_id = f.film_id
GROUP BY f.film_id
HAVING f.title = "Hunchback Impossible";

-- 2. List all films whose length is longer than the average length of all the films in the Sakila database.
SELECT title, length FROM sakila.film 
WHERE length > (SELECT AVG(length) as average_length FROM sakila.film);
-- 3. Use a subquery to display all actors who appear in the film "Alone Trip".
SELECT first_name, last_name FROM sakila.actor
WHERE actor_id IN ( SELECT actor_id FROM sakila.film_actor
	WHERE film_id IN (
    SELECT film_id FROM sakila.film
    WHERE title = "Alone Trip" 
    )
  );

-- 4.Sales have been lagging among young families, and you want to target family movies for a promotion. Identify all movies categorized as family films.
SELECT title from sakila.film
WHERE film_id IN (SELECT film_id from sakila.film_category
	WHERE category_id IN(
	SELECT category_id from sakila.category
	WHERE name = 'Family'
)
);

-- 5. Retrieve the name and email of customers from Canada using both subqueries and joins. To use joins, you will need to identify the relevant tables and their primary and foreign keys.
SELECT first_name, email FROM sakila.customer 
WHERE address_id IN (SELECT address_id FROM sakila.address
    WHERE city_id IN (
    SELECT city_id FROM sakila.city
    WHERE country_id IN (
    SELECT country_id FROM sakila.country 
    WHERE country = 'Canada')
)
);

SELECT c.first_name, c.email FROM sakila.customer as c
JOIN address as a 
on c.address_id = a.address_id
JOIN city as ci
on a.city_id = ci.city_id
JOIN country as co
on ci.country_id = co.country_id
where co.country = 'Canada';

CREATE TEMPORARY TABLE  prolific_actor  AS (SELECT actor_id, count(film_id) as number_films FROM sakila.film_actor 
GROUP BY actor_id
ORDER BY number_films desc
LIMIT 1);

SELECT actor_id FROM prolific_actor;



-- 7. Determine which films were starred by the most prolific actor in the Sakila database. A prolific actor is defined as the actor who has acted in the most number of films. First, you will need to find the most prolific actor and then use that actor_id to find the different films that he or she starred in.
CREATE TEMPORARY TABLE  prolific_actor  AS (SELECT actor_id, count(film_id) as number_films FROM sakila.film_actor 
GROUP BY actor_id
ORDER BY number_films desc
LIMIT 1);

SELECT actor_id FROM prolific_actor;
SELECT title FROM sakila.film 
WHERE film_id IN (SELECT film_id FROM film_actor
WHERE actor_id IN (SELECT actor_id FROM prolific_actor ) );

SELECT f.title FROM sakila.film as f
JOIN film_actor as fa
ON f.film_id = fa.film_actor;

-- 8. Find the films rented by the most profitable customer in the Sakila database. You can use the customer and payment tables to find the most profitable customer, i.e., the customer who has made the largest sum of payments.
CREATE TEMPORARY TABLE prolific_customer AS (
SELECT customer_id, SUM(amount) AS total_spent FROM sakila.payment
GROUP BY customer_id 
ORDER BY total_spent DESC 
LIMIT 1);

SELECT title FROM sakila.film WHERE film_id IN (
SELECT film_id FROM inventory WHERE inventory_id IN (
SELECT inventory_id FROM rental WHERE customer_id  IN (SELECT customer_id FROM prolific_customer)
)
);

CREATE TEMPORARY TABLE client_amount_spent AS (
	SELECT customer_id, SUM(amount) AS total_spent FROM sakila.payment
	GROUP BY customer_id 
	ORDER BY total_spent DESC);
    
SELECT * FROM sakila.client_amount_spent;
-- 9. Retrieve the client_id and the total_amount_spent of those clients who spent more than the average of the total_amount spent by each client. You can use subqueries to accomplish this.
CREATE TEMPORARY TABLE client_amount_spent AS (
	SELECT customer_id, SUM(amount) AS total_spent FROM sakila.payment
	GROUP BY customer_id 
	ORDER BY total_spent DESC);
SELECT customer_id, total_spent FROM  client_amount_spent
WHERE total_spent > (SELECT AVG(total_spent) AS avg_total_spent FROM (SELECT SUM(amount) AS total_spent FROM sakila.payment
	GROUP BY customer_id 
	ORDER BY total_spent DESC) as sub1 
    );

(SELECT AVG(total_spent) AS avg_total_spent FROM client_amount_spent);
