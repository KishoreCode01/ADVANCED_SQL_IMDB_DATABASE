Use imdb;
select * from director_mapping;
select * from genre;
select * from movie;
select * from names;
select * from ratings;
select * from role_mapping;

-- 1. Count the total number of records in each table of the database.

select count(*) as Number_Of_Records_director_mapping from director_mapping;
select count(*) as Number_Of_Records_genre from genre;
select count(*) as Number_Of_Records_movie from movie;
select count(*) as Number_Of_Records_names from names;
select count(*) as Number_Of_Records_ratings from ratings;
select count(*) as Number_Of_Records_role_mapping from role_mapping;

delimiter $$
Create procedure NO_OF_Records()
begin
	select count(*) as Number_Of_Records_director_mapping from director_mapping;
	select count(*) as Number_Of_Records_genre from genre;
	select count(*) as Number_Of_Records_movie from movie;
	select count(*) as Number_Of_Records_names from names;
	select count(*) as Number_Of_Records_ratings from ratings;
	select count(*) as Number_Of_Records_role_mapping from role_mapping;
end$$
delimiter ;

call NO_OF_Records();

select * from information_schema.tables where table_schema = "imdb";

-- 2. Identify which columns in the movie table contain null values.

select * from movie;
select * from movie where id is null or title is null or year is null or date_published is null or duration is null or country is null 
or worlwide_gross_income is null or languages is null or production_company is null;

select column_name,is_nullable from information_schema.columns where table_name = "movie";

-- 3. Determine the total number of movies released each year, and analyze how the trend changes month-wise.

select * from movie;
select count(title) as Movie_Count ,year from movie group by year;
select count(title) as Movie_Count,month(date_published) as Month from movie group by month(date_published) order by Month asc;
select count(title) as Movie_Count,month(date_published) as Month, Year from movie group by month(date_published),year order by year,Month asc;


-- 4. How many movies were produced in either the USA or India in the year 2019?

select * from movie;
/*/
select count(title) as Movie_Count, country from movie where country = "India";
select count(title) as Movie_Count, country from movie where country = "USA";
select count(title) as Movie_Count, country,year from movie where year = 2019 group by country having country = "USA";
/*/
select count(title) as Movie_Count, country, year from movie where year = 2019 group by country having (country = "USA" or Country = "India");

-- 5. List the unique genres in the dataset, and count how many movies belong exclusively to one genre.

select * from genre;
select count(genre) as No_Of_Movies,genre from genre group by genre order by count(genre);

-- 6. Which genre has the highest total number of movies produced?

select * from genre;
select distinct genre,count(genre) from genre group by genre order by count(genre) desc limit 1;


-- 7. Calculate the average movie duration for each genre.

select * from movie;
select * from genre;

select avg(m.duration) as Average_Duration,g.genre 
from movie m inner join genre g 
on m.id = g.movie_id 
group by g.genre order by avg(m.duration) asc;

-- 8. Identify actors or actresses who have appeared in more than three movies with an average rating below 5.

select * from ratings;
select * from role_mapping;

select count(rm.name_id),rm.name_id,rm.category,r.avg_rating
from  role_mapping rm inner join ratings r
on rm.movie_id = r.movie_id 
where r.avg_rating <5
group by rm.name_id,rm.category,r.avg_rating having rm.name_id >3;

-- 9. Find the minimum and maximum values for each column in the ratings table, excluding the movie_id column.

select * from ratings;

select min(avg_rating) as Min_avg_rating,max(avg_rating) as Max_avg_rating,
		min(total_votes) as Min_total_votes, max(total_votes) as Max_total_votes,
        min(median_rating) as Min_median_rating,max(median_rating) as Max_median_rating from ratings;


-- 10. Which are the top 10 movies based on their average rating?

select * from ratings;
select * from movie;

select m.title as Movie_Name,r.avg_rating
from ratings r inner join movie m
on r.movie_id = m.id
order by r.avg_rating desc limit 10;

-- 11. Summarize the ratings table by grouping movies based on their median ratings.

select * from ratings;
select * from movie;

select count(m.title) as Movie_Count,r.median_rating
from ratings r inner join movie m
on r.movie_id = m.id
group by r.median_rating order by r.median_rating asc;

-- 12. How many movies, released in March 2017 in the USA within a specific genre, had more than 1,000 votes?

select * from movie;
select * from genre;
select * from ratings;

select m.title as Movie_Name,m.date_published,m.year,m.country,r.total_votes,group_concat(g.genre) as Genre
from movie m inner join genre g
on m.id = g.movie_id 
inner join ratings r
on m.id = r.movie_id
where  month(m.date_published) = 3 
and  year = 2017
and r.total_votes > 1000 and m.country like '%USA%' group by m.title,m.date_published,m.year,m.country,r.total_votes order by r.total_votes asc;


-- 13. Find movies from each genre that begin with the word “The” and have an average rating greater than 8.

select * from movie;
select * from genre;
select * from ratings;

select m.title,group_concat(g.genre) as Genre,r.avg_rating
from movie m inner join genre g
on m.id = g.movie_id inner join ratings r
on m.id = r.movie_id
where r.avg_rating > 8
group by m.title,r.avg_rating having m.title like 'the%';

-- 14. Of the movies released between April 1, 2018, and April 1, 2019, how many received a median rating of 8?

select * from movie;
select * from ratings;

select m.title as Movie_Name,m.date_published,r.median_rating
from movie m inner join ratings r
on m.id = r.movie_id
where m.date_published between '2018-04-01' and '2019-04-01' 
and r.median_rating = 8 order by m.date_published asc;

-- 15. Do German movies receive more votes on average than Italian movies?

select * from movie;
select * from ratings;

select m.country,avg(r.total_votes) as Average_Vote
from movie m inner join ratings r
on m.id = r.movie_id 
where m.country = "Germany" or m.country = "Italy"
group by m.country;

-- 16. Identify the columns in the names table that contain null values.

select * from names;
select * from names where id is null or name is null or height is null or date_of_birth is null or known_for_movies is null;

select column_name,is_nullable from information_schema.columns where table_name = "names";

-- 17. Who are the top two actors whose movies have a median rating of 8 or higher?

select * from role_mapping;
select * from movie;
select * from ratings;
select * from Names;

select rm.name_id,n.name,rm.category,m.title as Movie_Name,r.median_rating
from role_mapping rm
inner join movie m
on rm.movie_id = m.id
inner join ratings r 
on rm.movie_id = r.movie_id 
inner join names n
on rm.name_id = n.id
where r.median_rating>=8 order by r.median_rating desc limit 2;

-- 18. Which are the top three production companies based on the total number of votes their movies received?

select * from Movie;
select  * from ratings;

select m.title as Movie_Name,m.production_company,r.total_votes
from movie m inner join ratings r
on m.id = r.movie_id order by r.total_votes desc limit 3;

-- 19. How many directors have worked on more than three movies?

select * from director_mapping;
select * from names;
select * from movie;

select count(dm.name_id) as Movie_count, dm.name_id,n.name as Director_Name
from director_mapping dm inner join names n
on dm.name_id = n.id
inner join movie m
on dm.movie_id = m.id
group by dm.name_id having Movie_count>3 order by Movie_count desc;

-- 20. Calculate the average height of actors and actresses separately.

select * from role_mapping;
select * from names;

select rm.category,avg(n.height) as Avg_Height
from role_mapping rm inner join names n
on rm.name_id = n.id
group by rm.category;

-- 21. List the 10 oldest movies in the dataset along with their title, country, and director.

select * from movie;
select * from director_mapping;
select * from names;

select dm.name_id,n.name as Director_Name,m.title as Movie_Name,m.date_published,m.country
from director_mapping dm inner join names n
on dm.name_id = n.id
inner join movie m
on dm.movie_id = m.id order by m.date_published asc limit 10;

-- 22. List the top 5 movies with the highest total votes, along with their genres.

select * from movie;
select * from ratings;
select * from genre;

select m.title,r.total_votes,group_concat(distinct g.genre) as Genre
from movie m inner join ratings r
on m.id = r.movie_id 
inner join genre g
on m.id = g.movie_id
group by m.title,r.total_votes
order by r.total_votes desc limit 5;

-- 23. Identify the movie with the longest duration, along with its genre and production company.

select * from Movie;
select * from genre;

select m.title as Movie_Name,m.duration,m.production_company,group_concat(g.genre) as Genre
from movie m inner join genre g
on m.id = g.movie_id
group by m.title,m.duration,m.production_company
having m.duration = (select max(m.duration) from movie m);

-- 24. Determine the total number of votes for each movie released in 2018.

select * from Movie;
select * from ratings;

select m.title as Movie_Name,m.year,r.total_votes
from movie m inner join ratings r
on m.id = r.movie_id where m.year = 2018 order by r.total_votes asc;

-- 25. What is the most common language in which movies were produced?
/*/
select char_length(languages), languages from movie;
select substring(languages,1,2),languages from movie;
select * from Movie;
select count(languages) from movie where languages like '%english%';
select count(languages) from movie where languages like '%german%';
select count(languages) from movie where languages like '%french%';

select Eng_lan,sum(count_eng),Ger_lan,sum(count_ger) FROM (
select 'english' as Eng_lan,
case
when m.languages like '%english%' then count(m.languages)
else 0 
end
as count_Eng,
'german' as Ger_lan,
case
when m.languages like '%german%' then count(m.languages)
else 0 
end count_ger
from movie m group by m.languages) as X group by Eng_lan,Ger_lan;
/*/
select
    Languages,
    COUNT(*) as Movie_count
from (
    select
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(languages, ',', n.n), ',', -1)) as Languages
    from movie
    inner join (
        SELECT 1 AS n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5
        UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9 UNION ALL SELECT 10
    ) n on CHAR_LENGTH(languages) - CHAR_LENGTH(replace(languages, ',', '')) >= n.n - 1
) sub
group by languages
order by movie_count desc;










