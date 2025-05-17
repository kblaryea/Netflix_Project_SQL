```sql
-- Netflix Project

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


	
Select 
	Distinct type
From netflix;


--BUSINESS ANALYSIS

--1. Count the number if Movies vs TV Shows

Select 
	type, 
	count (type) as total_content
from netflix
Group by type;

--2. Find the most common rating for movies vs TV shows

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


-- 3. List all movies released in a specific year (eg. 2020)

Select *
From netflix
Where release_year = 2020 and type = 'Movie';


--4. Find the top 5 countries with the most content on netflix

Select 
	Trim(Unnest(string_to_array(country, ','))) as new_country,
	count(show_id) as total_content
	
From netflix
Group by new_country
Order by total_content desc
limit 5;

--5. Identify the longest movie

select title,  
	substring(duration, 1,position ('m' in duration)-1)::int as duration
from Netflix
where type = 'Movie' and duration is not null
order by duration desc
limit 1;


--6. Find content added in the last 5 years

Select 
	*,
	TO_DATE(date_added, 'Month DD, YYYY')
From netflix
Where TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years',


--7. Find all the movies/tv shows by director 'Rajiv Chilaka'!


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
	Split_Part(duration, ' ', 1)::numeric > 5	

--9. Count the number of content items in each genre

Select 
	trim(unnest(string_to_array(listed_in, ','))) as genre,
	count(show_id) as number_of_content
From netflix
Group by genre
Order by number_of_content desc;


--10. Find each year and the share of content release by India on Netflix
--return top 5 years with highest share content release.

Select 
	Extract(Year from To_date(date_added, 'Month DD, YYYY')) as year,
	count(show_id) as no_of_content,
	round(count(*)::numeric/(Select count(*) from netflix where country ilike 'India')::numeric * 100, 2) as share_of_content
From netflix
where country Ilike '%India%'
group by year;

--11. List all the movies that are documentaries

Select * 
From netflix
Where 
	listed_in ilike '%Documentaries%' 
	and
	type = 'Movie';

--12. Find all content without a director
Select *
From netflix
Where
	director is Null;


--13. Find how many movies actor 'Salman Khan' appeared in last 5 years

Select 
	*
From netflix
where 
	casts ilike '%Salman Khan%' and 
	release_year >= Extract(Year from Current_date) - 10;



--14. Find the top 10 actors who have appeared in the highest number of movies produced in India

Select
	trim(unnest(string_to_array(casts, ','))) as cast_name,
	count(show_id) as no_of_content
From netflix
Where country ilike '%India%'
Group by cast_name
Order by no_of_content desc
limit 10;

/*
15. CAtegorize the content based on the presence of the keywords 'kill' and 'voilence'in the 
description field. Label content containing these keywords as 'Bad' and all other content as 'Good'.
Count how many items fall into each category
*/

Select 
	t1.judgement,
	count(t1.*)
From
(
Select
	show_id,
	description,
	Case when description ILIKE '%kill%' or description ILIKE '%violence%' then 'Bad Content'
	Else 'Good Content'
	End as judgement
From netflix
)t1
Group by judgement;

```
	
