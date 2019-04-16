USE sakila;

-- 1a. Display the first and last names of all actors from the table actor
SELECT first_name,last_name 
FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the 
-- 	   column Actor Name.
SELECT concat(UPPER(first_name),"  ",UPPER(last_name)) AS actor_name 
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the 
-- 	   first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id,first_name,last_name 
FROM actor 
WHERE first_name LIKE "Joe";

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT * 
FROM actor 
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT last_name,first_name,actor_id,last_update 
FROM actor 
WHERE last_name 
LIKE '%LI%';

/* 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan,
 Bangladesh, and China */
 
SELECT country_id,country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


/*3a. You want to keep a description of each actor. You don't think you will be performing queries on a 
	  description, so create a column in the table actor named description and use the data type BLOB 
	  (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).*/
      
ALTER TABLE actor 
ADD COLUMN description BLOB(1000);

DESCRIBE actor;

/*Differences between varchar and BLOB are
 1)BLOB just like TEXT is stored off the table with the table just having a pointer to the location of the 
	actual storage.
	While VARCHAR is stored inline with the table.
 2)BLOB is only used if you have complex data type serialized, that is if you want to store in a single table a 
   complex class.
   While String attributes should be stored as VARCHAR. */
 
 /*3b. Very quickly you realize that entering descriptions for each actor is too much effort. 
	   Delete the description column.*/

ALTER TABLE actor
DROP COLUMN description;

DESCRIBE actor;

/*4a. List the last names of actors, as well as how many actors have that last name.*/

SELECT last_name , COUNT(last_name) as last_name_count
FROM actor
GROUP BY  last_name;

/*4b. List last names of actors and the number of actors who have that last name,
 but only for names that are shared by at least two actors */

SELECT last_name,COUNT(last_name) as last_name_count
FROM actor
GROUP BY last_name
HAVING last_name_count>1;

/*4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
	  write a query to fix the record.*/
SELECT * 
FROM actor
WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

SET SQL_SAFE_UPDATES = 0;

UPDATE ACTOR
SET first_name='HARPO'
WHERE first_name='GROUCHO' AND last_name='WILLIAMS';

SET SQL_SAFE_UPDATES = 1;
/* 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the 
	correct name after all! In a single query, if the first name of the actor is currently HARPO, 
    change it to GROUCHO.*/

SELECT * 
FROM actor
WHERE first_name='HARPO' AND last_name='WILLIAMS';

SET SQL_SAFE_UPDATES = 0;

UPDATE ACTOR
SET first_name='GROUCHO'
WHERE first_name='HARPO' AND last_name='WILLIAMS';
 
SET SQL_SAFE_UPDATES = 1;

/*5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
*/

SHOW CREATE TABLE ADDRESS;


/* 6a. Use JOIN to display the first and last names, as well as the address, of each staff member.
 Use the tables staff and address:*/

SELECT s.first_name,s.last_name,a.address
FROM address a
INNER JOIN staff s
ON a.address_id=s.address_id;

/*6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
Use tables staff and payment.
*/

SELECT s.first_name,s.last_name,SUM(p.amount),p.payment_date
FROM staff s
INNER JOIN payment p
ON s.staff_id=p.staff_id
WHERE p.payment_date like "2005-08%"
GROUP BY s.staff_id ;

/* 6c. List each film and the number of actors who are listed for that film. Use tables film_actor 
	and film.Use inner join. */

SELECT f.title, COUNT(fa.actor_id) AS actor_count
FROM film f 
INNER JOIN film_actor fa on f.film_id=fa.film_id
GROUP BY f.title;

/* 6d. How many copies of the film Hunchback Impossible exist in the inventory system? */

SELECT f.title,i.film_id,COUNT(i.film_id) AS number_of_copies
FROM film f
INNER JOIN  inventory i ON f.film_id=i.film_id
GROUP BY film_id 
HAVING  title='Hunchback Impossible';

/*6e. Using the tables payment and customer and the JOIN command, 
list the total paid by each customer. List the customers alphabetically by last name:*/


SELECT c.first_name,c.last_name,SUM(p.amount) AS total_paid 
FROM customer c 
INNER JOIN payment p ON c.customer_id=p.customer_id 
GROUP BY concat(UPPER(first_name),"  ",UPPER(last_name))
ORDER BY c.last_name;

/*7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
	  As an unintended consequence, films starting with the letters K and Q have also soared in 
      popularity. Use subqueries to display the titles of movies starting with the letters K and Q
      whose language is English.*/

/* Using subqueries */
SELECT title FROM film WHERE UPPER(title) 
LIKE "K%" OR UPPER(title) LIKE "Q%" 
AND language_id IN
(
	SELECT l.language_id FROM language
	WHERE upper(name)="ENGLISH"
 );

/* Using Joins */
SELECT c.title, c.language_id, c2.name
FROM film c INNER JOIN language c2
ON c.language_id = c2.language_id
WHERE c.title LIKE ("Q%") OR c.title LIKE ("K%") AND c2.name = 'English';

/*7b. Use subqueries to display all actors who appear in the film Alone Trip.*/

SELECT first_name,last_name 
FROM actor 
WHERE actor_id IN
(
	SELECT actor_id
    FROM film_actor
	WHERE  film_id 	IN 
	(
		select film_id from film where title="Alone Trip"
	)
);

/*7c. You want to run an email marketing campaign in Canada, for which you will need the names and 
email addresses of all Canadian customers. Use joins to retrieve this information. */

SELECT CONCAT(first_name," ",last_name) AS full_name,email  
FROM customer 
WHERE store_id IN 
( 
	SELECT SID 
    FROM customer_list 
    WHERE country="CANADA"
);

/*7d. Sales have been lagging among young families, and you wish to target
 all family movies for a promotion. Identify all movies categorized as 
 family films.*/
 
SELECT title 
FROM film 
WHERE film_id IN 
( 
	SELECT film_id FROM film_category 
    WHERE category_id IN
		( 
			SELECT category_id FROM category WHERE UPPER(name) = "FAMILY"
		)
);
 
 /*7e. Display the most frequently rented movies in descending order. */

SELECT f.title,COUNT(i.inventory_id) frequency 
FROM  inventory i
INNER JOIN film f  ON i.film_id=f.film_id
GROUP BY i.film_id ORDER BY frequency DESC;


/*7f. Write a query to display how much business, in dollars, each store brought in.*/

SELECT t.store_id,SUM(P.amount) AS amount_in_$  
FROM payment p 
INNER JOIN staff s ON p.staff_id=s.staff_id
INNER JOIN store t ON s.store_id=t.store_id
GROUP BY p.staff_id;

/* 7g. Write a query to display for each store its store ID, city, and country.*/
SELECT s.store_id,c.city,b.country 
FROM store s
INNER JOIN address a ON s.address_id=a.address_id
INNER JOIN city c ON a.city_id=c.city_id
INNER JOIN country b ON c.country_id=b.country_id;

/*7h. List the top five genres in gross revenue in descending order. (Hint: you may 
need to use the following tables: category, film_category, inventory, payment, and rental.)*/


SELECT c.name,SUM(p.amount) AS revenue_in_$ 
FROM payment p 
INNER JOIN rental r ON p.rental_id=r.rental_id
INNER JOIN inventory i ON r.inventory_id=i.inventory_id 
INNER JOIN film_category f ON  i.film_id=f.film_id
INNER JOIN category c ON f.category_id=c.category_id
GROUP BY c.category_id ORDER BY revenue_in_$ DESC LIMIT 5;

/*8a. In your new role as an executive, you would like to have an easy way of viewing 
the Top five genres by gross revenue. Use the solution from the problem above to create a view.
If you haven't solved 7h, you can substitute another query to create a view.*/

CREATE VIEW generes_by_revenue AS
SELECT c.name,SUM(p.amount) AS revenue_in_$
FROM payment p 
INNER JOIN rental r ON p.rental_id=r.rental_id
INNER JOIN inventory i ON r.inventory_id=i.inventory_id 
INNER JOIN film_category f ON  i.film_id=f.film_id
INNER JOIN category c ON f.category_id=c.category_id
GROUP BY c.category_id 
ORDER BY revenue_in_$ DESC LIMIT 5;

/*8b. How would you display the view that you created in 8a?*/

SELECT * 
FROM generes_by_revenue;

/*8c. You find that you no longer need the view top_five_genres. Write a query to delete it.*/
DROP VIEW generes_by_revenue;




