USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:

-- There are two ways 
-- First

SELECT table_name, table_rows
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'imdb'; 

-- Second 
/*select count(*) AS  genre_rows from genre imdb;
select count(*) AS movie_rows from movie imdb;
select count(*) AS director_mapping_rows from director_mapping imdb;
select count(*) AS role_mapping_rows from role_mapping imdb;
select count(*) AS names_rows from names imdb;
select count(*) AS ratings_rows from ratings imdb;*/



-- Q2. Which columns in the movie table have null values?
-- Type your code below:
		

WITH null_count_table AS
(
	SELECT 'id' AS column_name, COUNT(*) - COUNT(id) as null_count FROM movie
	UNION ALL
	SELECT 'title', COUNT(*) - COUNT(title) FROM movie
	UNION ALL
	SELECT 'year', COUNT(*) - COUNT(year) FROM movie
	UNION ALL
	SELECT 'date_published', COUNT(*) - COUNT(date_published) FROM movie
	UNION ALL
	SELECT 'duration', COUNT(*) - COUNT(duration) FROM movie
	UNION ALL
	SELECT 'country', COUNT(*) - COUNT(country) FROM movie
	UNION ALL
	SELECT 'worlwide_gross_income', COUNT(*) - COUNT(worlwide_gross_income) FROM movie
	UNION ALL
	SELECT 'languages', COUNT(*) - COUNT(languages) FROM movie
	UNION ALL
	SELECT 'production_company', COUNT(*) - COUNT(production_company) FROM movie
    )
    SELECT column_name
    FROM null_count_table
    WHERE null_count != 0;
   


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT year, COUNT(title) as number_of_movies 
FROM movie
GROUP BY year
ORDER BY year;

-- WE SEE A DECREASING TREND OF MOVIES YEAR ON YEAR ---

SELECT MONTH(date_published) AS month_num, COUNT(title) as number_of_movies 
FROM movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);



/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT COUNT(id) AS movie_count_USA_OR_India
FROM movie
WHERE year = 2019
AND (country LIKE '%USA%' OR country LIKE '%INDIA%'); -- Yes the exact number is 1059



/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

-- Both queries can fetch unique list of the genres present in the data set
SELECT DISTINCT genre FROM genre;

SELECT genre FROM genre
GROUP BY genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:


SELECT g.genre, count(m.title) AS higest_number -- OVERALL HIGHEST NUMBER OF MOVIES PRODUCED
FROM movie AS m
LEFT JOIN genre AS g
ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY COUNT(m.title) DESC LIMIT 1;

/*SELECT g.genre,year, count(m.title) AS higest_number_year  -- OVERALL HIGHEST NUMBER OF MOVIES PRODUCED BASIS THE YEAR
FROM movie AS m
LEFT JOIN genre AS g
ON m.id = g.movie_id
group by g.genre,year
order by count(m.title) DESC LIMIT 1;*/

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:


-- USING CTE TABLE (How many movies belong to only one genre?)
WITH movie_list_genre_Count AS 
(
	SELECT m.title, COUNT(g.genre) as Genre_count
	FROM movie AS m
	INNER JOIN genre AS g
	ON m.id = g.movie_id
	GROUP BY m.title
    HAVING Genre_count = 1
    )
SELECT COUNT(title) AS movies_with_one_genre
FROM movie_list_genre_Count;




/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre, avg(m.duration) AS avg_duration 
FROM movie AS m
LEFT JOIN genre AS g
ON m.id = g.movie_id
GROUP BY g.genre
ORDER BY avg(m.duration);



/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


-- Done Using two ways first is using CTE table i find this easy:
-- SAECOND WAY IS WITHOUT USING CTE

WITH genre_movie_count AS(
SELECT g.genre, count(m.title) as movie_count
FROM movie AS m
LEFT JOIN genre AS g
ON m.id = g.movie_id
GROUP BY g.genre)
SELECT * FROM
(SELECT *,
       RANK() OVER(ORDER BY movie_count DESC) AS gener_rank
FROM genre_movie_count) Ranked
WHERE genre = "Thriller";


/* Another way of doing the above question ---
SELECT g.genre, count(m.title) as movie_count,
RANK() OVER(ORDER BY count(m.title) DESC) AS gener_rank
FROM movie AS m
LEFT JOIN genre AS g
ON m.id = g.movie_id
GROUP BY g.genre
HAVING GENRE = "THRILLER";
*/



/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT min(avg_rating) AS min_avg_rating, 
max(avg_rating) AS max_avg_rating, 
min(total_votes) AS min_total_votes, 
max(total_votes) AS max_total_votes, 
min(median_rating) AS min_median_rating, 
max(median_rating) AS max_median_rating
FROM ratings;




/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- Keep in mind that multiple movies can be at the same rank. You only have to find out the top 10 movies (if there are more than one movies at the 10th place, consider them all.)

WITH ranked_movies AS (
SELECT m.title, r.avg_rating, 
DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) AS movie_rank
FROM movie AS m
LEFT JOIN ratings AS r
ON m.id = r.movie_id)
SELECT * FROM ranked_movies
WHERE movie_rank < 11;



/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have


SELECT r.median_rating, count(m.title) as movie_count
FROM movie AS m
LEFT JOIN ratings AS r
ON m.id = r.movie_id
GROUP BY r.median_rating
ORDER BY r.median_rating;







/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:


With hit_movies_table AS(
SELECT m.production_company, COUNT(m.title) AS movie_count,
DENSE_RANK() OVER(ORDER BY COUNT(m.title) DESC) AS prod_company_rank
FROM movie AS m
LEFT JOIN ratings AS r
ON m.id = r.movie_id
WHERE r.avg_rating > 8
AND m.production_company IS NOT NULL
GROUP BY m.production_company
ORDER BY COUNT(m.title) DESC)
SELECT * FROM hit_movies_table
WHERE prod_company_rank = 1;




-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre, COUNT(m.title) AS movie_count
FROM movie AS m
INNER JOIN genre AS g
ON m.id = g.movie_id
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE m.date_published like "2017-03%"
AND r.total_votes >1000
AND COUNTRY LIKE "%USA%"
GROUP BY g.genre
ORDER BY movie_count DESC;




-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT m.title, r.avg_rating, g.genre 
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
INNER JOIN genre AS g
ON m.id = g.movie_id
WHERE m.title like "The%"
AND r.avg_rating > 8
ORDER BY r.avg_rating;





-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:

SELECT COUNT(m.title) AS Number_Movie_released
FROM movie AS m
INNER JOIN ratings AS r
ON m.id = r.movie_id
WHERE m.date_published BETWEEN '2018-04-01' AND '2019-04-01'
AND r.median_rating = 8;




-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:


WITH total_Votes_german_italian AS (
SELECT 
        CASE 
            WHEN m.languages LIKE "%German%" THEN 'German'
            WHEN m.languages LIKE "%Italian%" THEN 'Italian'
            END AS language,
        r.total_votes FROM
        movie AS m
	LEFT JOIN ratings AS r ON m.id = r.movie_id
    WHERE m.languages IS NOT NULL)
    SELECT language, SUM(total_votes) 
    FROM total_Votes_german_italian
    WHERE language IS NOT NULL
    GROUP BY language;


-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:



SELECT 
     COUNT(*) - COUNT(name) AS name_nulls, 
     COUNT(*) - COUNT(height) AS height_nulls, 
     COUNT(*) - COUNT(date_of_birth) AS date_of_birth_nulls, 
     COUNT(*) - COUNT(known_for_movies) AS known_for_movies_nulls
FROM names;





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

-- top three directors , top three genres whose movie, average rating > 8


    
WITH Top_genres AS (
	-- Find the top 3 genres with the most movies having avg_rating > 8
	SELECT g.genre, COUNT(m.title) AS top_genre
	FROM movie as m
	LEFT JOIN genre as g
	ON m.id = g.movie_id
	LEFT JOIN ratings as r
	ON m.id = r.movie_id
	LEFT JOIN director_mapping as d
	ON m.id = d.movie_id
	LEFT JOIN names as n
	ON n.id = d.name_id
	WHERE r.avg_rating > 8
	GROUP BY g.genre
	ORDER BY top_genre DESC LIMIT 3)
-- Find the top 3 directors within those top genres
SELECT n.name AS director_name, COUNT(title) AS movie_count
FROM movie as m
LEFT JOIN genre as g
ON m.id = g.movie_id
LEFT JOIN ratings as r
ON m.id = r.movie_id
LEFT JOIN director_mapping as d
ON m.id = d.movie_id
LEFT JOIN names as n
ON n.id = d.name_id
WHERE r.avg_rating > 8 
AND n.name IS NOT NULL
AND g.genre IN (SELECT Top_genres.genre FROM Top_genres)
GROUP BY n.name 
ORDER BY count(title) DESC LIMIT 3;






/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT n.name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM ratings AS r
LEFT JOIN role_mapping AS rm
ON rm.movie_id = r.movie_id
LEFT JOIN names AS n
ON rm.name_id = n.id
WHERE r.median_rating >= 8 AND rm.category = 'actor'
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2; -- Get actors and count of movies with median rating >= 8


/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:


WITH production_company_votes AS (
SELECT m.production_company AS production_company, sum(r.total_votes) AS vote_count
FROM movie AS m
LEFT JOIN ratings AS r
ON m.id = r.movie_id
WHERE m.production_company IS NOT NULL
GROUP BY m.production_company
ORDER BY vote_count DESC)
SELECT * FROM 
-- Finding the rank of production_company
(SELECT production_company, vote_count,
DENSE_RANK() OVER(ORDER BY vote_count DESC) AS prod_comp_rank
FROM production_company_votes) AS ranking
WHERE prod_comp_rank < 4;





/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

WITH top_indian_actor AS
-- Actors with movies released in India based on their average ratings
(
	SELECT n.name AS actor_name,sum(r.total_votes) AS total_votes, count(m.title) AS movie_count, ROUND((SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes)),2) AS actor_avg_rating 
	FROM names as n
	LEFT JOIN role_mapping as rm
	ON n.id = rm.name_id
	LEFT JOIN movie as m
	ON m.id = rm.movie_id
	LEFT JOIN ratings as r
	ON m.id = r.movie_id
	WHERE m.country LIKE "%india%"
	AND rm.category = "Actor"
	GROUP BY n.name
	HAVING count(m.title) > 4
	ORDER BY count(m.title) DESC
    )
SELECT * FROM
-- Fetching Rank based on top Indian Actors
	(SELECT *, 
	DENSE_RANK() OVER(ORDER BY actor_avg_rating  DESC, total_votes DESC) AS actor_rank
	FROM top_indian_actor) RANKED
WHERE actor_rank = 1;


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:


WITH top_indian_Actress AS
-- Actresses in hindi movies released in India based on their average ratings
(
	SELECT n.name AS Actress_name, sum(r.total_votes) AS total_votes, count(m.title) AS movie_count, ROUND((SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes)),2) AS actress_avg_rating
	FROM names as n
	LEFT JOIN role_mapping as rm
	ON n.id = rm.name_id
	LEFT JOIN movie as m
	ON m.id = rm.movie_id
	LEFT JOIN ratings as r
	ON m.id = r.movie_id
	WHERE m.country LIKE "%india%"
	AND m.languages LIKE "%Hindi%"
	AND rm.category = "Actress"
	GROUP BY n.name
	HAVING movie_count >= 3
	ORDER BY count(m.title) DESC)
SELECT * FROM
-- Fetching Rank based on top Indian Actresses 
	(SELECT *, 
	DENSE_RANK() OVER(ORDER BY actress_avg_rating DESC, total_votes DESC) AS Actress_rank
	FROM top_indian_Actress) RANKED
WHERE Actress_rank <6;







/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Consider thriller movies having at least 25,000 votes. Classify them according to their average ratings in
   the following categories:  

			Rating > 8: Superhit
			Rating between 7 and 8: Hit
			Rating between 5 and 7: One-time-watch
			Rating < 5: Flop
	
    Note: Sort the output by average ratings (desc).
--------------------------------------------------------------------------------------------*/
/* Output format:
+---------------+-------------------+
| movie_name	|	movie_category	|
+---------------+-------------------+
|	Get Out		|			Hit		|
|		.		|			.		|
|		.		|			.		|
+---------------+-------------------+*/

-- Type your code below:

WITH Thriller_movie_category AS 
-- thriller movies having at least 25,000 votes
(
	SELECT m.title AS movie_name, r.avg_rating
	FROM movie as m
	LEFT JOIN ratings as r
	ON m.id = r.movie_id
	LEFT JOIN genre as g
	ON m.id = g.movie_id
	WHERE r.total_votes > 25000
	AND g.genre = "thriller")
SELECT movie_name,
-- Classifed Thriller_movie_category according to their average ratings
    CASE 
        WHEN avg_rating > 8 THEN 'Superhit'
        WHEN avg_rating between 7 and 8 THEN 'Hit'
        WHEN avg_rating between 5 and 7 THEN "One-time-watch"
        ELSE 'Flop'
    END AS movie_category
FROM Thriller_movie_category
ORDER BY avg_rating DESC;





/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:


WITH genre_avg AS (
-- genre-wise average duration
    SELECT g.genre, 
           AVG(m.duration) AS avg_duration
    FROM movie AS m
    JOIN genre AS g ON m.id = g.movie_id
    WHERE m.duration IS NOT NULL
    GROUP BY g.genre
)
SELECT genre,
-- Genre-wise running total and moving average of the average movie duration 
       avg_duration,
       SUM(avg_duration) OVER (ORDER BY genre) AS running_total_duration,
       AVG(avg_duration) OVER (ORDER BY genre ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_duration
FROM genre_avg
ORDER BY genre;


-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

    
WITH Q_26 AS (
-- Cleaning the data required to find highest-grossing movies of each year that belong to the top three genres
  SELECT 
    g.genre, 
    m.year, 
    m.title, 
    CASE  
      WHEN m.worlwide_gross_income LIKE 'INR%'  
      THEN CAST(SUBSTRING(m.worlwide_gross_income, 5) AS DECIMAL) * 0.012  
      ELSE CAST(REPLACE(m.worlwide_gross_income, '$', '') AS DECIMAL)  
    END AS worlwide_gross_income
  FROM movie AS m  
  INNER JOIN genre AS g  
  ON m.id = g.movie_id  
), 

Top_genres AS (
-- Finding Top three genres basis movie_Count
	SELECT g.genre AS top_genre
	FROM movie AS m  
	LEFT JOIN genre AS g  
	ON m.id = g.movie_id  
	LEFT JOIN ratings AS r  
	ON m.id = r.movie_id  
	LEFT JOIN director_mapping AS d  
	ON m.id = d.movie_id  
	LEFT JOIN names AS n  
	ON n.id = d.name_id 
	GROUP BY g.genre  
	ORDER BY count(m.title) DESC  
	LIMIT 3
)

SELECT * FROM (
-- five highest-grossing movies of each year that belong to the top three genres
SELECT 
    Q_26.genre AS genre, 
    Q_26.year AS year, 
    Q_26.title AS movie_name, 
    Q_26.worlwide_gross_income AS worldwide_gross_income,
    DENSE_RANK() OVER(PARTITION BY Q_26.year ORDER BY Q_26.worlwide_gross_income DESC) AS ranked
FROM Q_26
WHERE Q_26.genre IN (SELECT * FROM Top_genres)
ORDER BY Q_26.YEAR, Q_26.worlwide_gross_income DESC) AS ranking_year
WHERE ranked <6;

-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+ 
*/

WITH top_production_house AS (
-- top production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies
	SELECT m.production_company AS production_company, count(m.title) AS movie_count
	FROM movie AS m
	LEFT JOIN ratings AS r
	ON m.id = r.movie_id
	WHERE m.languages LIKE "%,%"
	AND m.production_company IS NOT NULL
	AND r.median_rating >=8
	GROUP BY m.production_company
	ORDER BY movie_count DESC
    )
    SELECT * FROM 
    (SELECT *,
    DENSE_RANK() OVER (ORDER BY movie_count DESC) AS prod_comp_rank
    FROM top_production_house) ranked
    WHERE prod_comp_rank <3;





-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language



-- Q28. Who are the top 3 actresses based on the number of Super Hit movies (Superhit movie: average rating of movie > 8) in 'drama' genre?

-- Note: Consider only superhit movies to calculate the actress average ratings.
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes
-- should act as the tie breaker. If number of votes are same, sort alphabetically by actress name.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	  actress_avg_rating |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.6000		     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/

-- Type your code below:
WITH top_indian_Actress AS
-- Top 3 actresses based on the number of Super Hit movies basis average rating of movie > 8 in 'drama' genre
(
	SELECT n.name AS Actress_name, sum(r.total_votes) AS total_votes, count(m.title) AS movie_count, ROUND((SUM(r.avg_rating * r.total_votes) / SUM(r.total_votes)),2) AS actress_avg_rating
	FROM names as n
	LEFT JOIN role_mapping as rm
	ON n.id = rm.name_id
	LEFT JOIN movie as m
	ON m.id = rm.movie_id
	LEFT JOIN ratings as r
	ON m.id = r.movie_id
	LEFT JOIN genre as g
	ON m.id = g.movie_id
	WHERE r.avg_rating > 8
	AND g.genre = "Drama"
	AND rm.category = "Actress"
	GROUP BY n.name
	ORDER BY count(m.title) DESC)
SELECT * FROM 
	(SELECT *, 
	DENSE_RANK() OVER(ORDER BY actress_avg_rating DESC, total_votes DESC) AS Actress_rank
	FROM top_indian_Actress) RANKED
WHERE Actress_rank <4
ORDER BY Actress_rank, Actress_name;







/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

WITH movie_dating AS (
-- Finding next movie date and data to find details for top 9 directors 
    SELECT 
        d.name_id AS director_id, 
        n.name AS director_name, 
        m.title,
        m.date_published AS movie_date,
        r.avg_rating,
        r.total_votes,
        m.duration,
        LEAD(m.date_published) OVER (PARTITION BY d.name_id ORDER BY m.date_published) AS next_movie_date
    FROM director_mapping AS d
    INNER JOIN names AS n ON d.name_id = n.id
    INNER JOIN movie AS m ON m.id = d.movie_id
    INNER JOIN ratings AS r ON m.id = r.movie_id
)
SELECT 
-- Finding aggregated data to find details for top 9 directors 
    director_id, 
    director_name, 
    COUNT(title) AS number_of_movies, 
    AVG(DATEDIFF(next_movie_date, movie_date)) AS avg_inter_movie_days,
    (SUM(avg_rating * total_votes) / SUM(total_votes)) AS avg_rating, 
    SUM(total_votes) AS total_votes, 
    MIN(avg_rating) AS min_rating, 
    MAX(avg_rating) AS max_rating, 
    SUM(duration) AS total_duration
FROM movie_dating
WHERE next_movie_date IS NOT NULL  -- Moved filtering here
GROUP BY director_id, director_name
ORDER BY number_of_movies DESC
LIMIT 9;