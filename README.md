# Netflix Movies and TV Shows Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
Drop Table if exists netflix;
Create Table netflix
	(
		show_id varchar(10),
		type varchar(10),
		title varchar(150),
		director varchar(208),
		casts varchar(1000),
		country varchar(150),
		date_added varchar(50),
		release_year int,
		rating varchar(10),
		duration varchar(15),
		listed_in varchar(100),
		description varchar (250)
	);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
Select 
	type, 
	count (*) as total_content
from netflix
Group by type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
Select t1.*
From
(
Select 
	type, 
	rating,
	count(rating) as common_rating,
	Rank() Over(Partition by type Order by count(rating) desc) as ranking
From netflix
Group by type, rating) as t1
Where ranking = 1;

```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
Select *
From netflix
Where release_year = 2020 and type = 'Movie';
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 10 Countries with the Most Content on Netflix

```sql
Select 
	Trim(Unnest(string_to_array(country, ','))) as new_country,
	count(show_id) as total_content
	
From netflix
Group by new_country
Order by total_content desc
limit 10;
```

![](https://github.com/kblaryea/Netflix_Project_SQL/blob/main/Top_10_countries.png)

#### Remarks: 
United States has the highest content total with 3,690 items. India follows with 1,046, and the United Kingdom comes third with 806. Other notable countries include Canada (445), France (393), and Japan (318). The data shows a wide global distribution, but content is heavily concentrated in a few top countries.

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie
**Objective:** Find the movie with the longest duration.

```sql
select title,  
	substring(duration, 1,position ('m' in duration)-1)::int as duration
from Netflix
where type = 'Movie' and duration is not null
order by duration desc
limit 1;
```

#### Remarks: 
The longest movie is Black Mirroe: Bandersnatch, which has a duration of 312 minutes


### 6. Find Content Added in the Last 5 Years

```sql
Select 
	*,
	TO_DATE(date_added, 'Month DD, YYYY')
From netflix
Where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';

```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
Select *
From
(
Select 
	*,
	trim(unnest(string_to_array(director, ','))) as director_name
from netflix) as t1
where director_name = 'Rajiv Chilaka'

--Alternative

Select *
From netflix
Where director ilike '%Rajiv Chilaka%'

```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT *
FROM netflix
WHERE type = 'TV Show'
  AND SPLIT_PART(duration, ' ', 1)::INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
Select *
From netflix
Where director ilike '%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons
Select t1.*
From
(
Select *,
	substring(duration, 1, position('S' in duration)-1)::int as duration1
From netflix
Where duration ilike '%Season%'
) as t1

Where t1.duration1 > 5;

--Alternatively

Select
	*, 
	Split_Part(duration, ' ', 1)::numeric as seasons
From netflix
Where 
	type = 'TV Show' and
	Split_Part(duration, ' ', 1)::numeric > 5;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        COUNT(show_id)::numeric /
        (SELECT COUNT(show_id) FROM netflix WHERE country = 'India')::numeric * 100, 2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT * 
FROM netflix
WHERE director IS NULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT * 
FROM netflix
WHERE casts LIKE '%Salman Khan%'
  AND release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT 
    UNNEST(STRING_TO_ARRAY(casts, ',')) AS actor,
    COUNT(*)
FROM netflix
WHERE country = 'India'
GROUP BY actor
ORDER BY COUNT(*) DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.



## Author - Zero Analyst

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media and join our community:

- **YouTube**: [Subscribe to my channel for tutorials and insights](https://www.youtube.com/@zero_analyst)
- **Instagram**: [Follow me for daily tips and updates](https://www.instagram.com/zero_analyst/)
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/najirr)
- **Discord**: [Join our community to learn and grow together](https://discord.gg/36h5f2Z5PK)

Thank you for your support, and I look forward to connecting with you!
