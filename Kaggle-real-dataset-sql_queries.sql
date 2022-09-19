ALTER TABLE ATHLETE_EVENTS 
modify event varchar2(150)

ALTER TABLE ATHLETE_EVENTS 
modify event varchar2(150)

ALTER TABLE ATHLETE_EVENTS 
modify age varchar2(10)    -- age had NA VALUES so getting error if it was INTEGER

SELECT * FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS;

SELECT * FROM SQLPORTFOLIOPROJECTS.NOC_REGIONS nr ;

--SQL QUERIES
--1. How many Olympics games have been held?

SELECT count(DISTINCT GAMES)  AS total_olympic_games FROM  SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ;
 
--2. List down all Olympics games held so far.

SELECT  distinct oh."Year" ,oh.season,oh.city FROM  SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS oh order by 1;

   
--3. Mention the total no of nations who participated in each Olympics game?

SELECT GAMES ,count(DISTINCT nr.REGION)  
FROM  SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae, SQLPORTFOLIOPROJECTS.NOC_REGIONS nr 
WHERE ae.NOC = nr.NOC 
GROUP BY GAMES 
ORDER BY Games ;

--4. Which year saw the highest and lowest no of countries participating in Olympics?

WITH total_countries AS (SELECT  ae.GAMES , count(DISTINCT(nr.REGION)) cntry_cnt
FROM  SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae, SQLPORTFOLIOPROJECTS.NOC_REGIONS nr 
WHERE ae.NOC = nr.NOC 
GROUP BY ae.GAMES )

SELECT DISTINCT 
 last_value(games) OVER (ORDER BY cntry_cnt RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) least_played_game, 
 last_value(cntry_cnt) OVER (ORDER BY cntry_cnt RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) Lowest_no_cntry,
 FIRST_VALUE(games) OVER (ORDER BY cntry_cnt  RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) highest_played_game,
 FIRST_VALUE(cntry_cnt) OVER (ORDER BY cntry_cnt  RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING ) highest_no_cntry
FROM total_countries
ORDER BY 1 ;


--5. Which nation has participated in all the Olympics games?

SELECT nr.REGION, count(DISTINCT(games))
FROM  SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae, SQLPORTFOLIOPROJECTS.NOC_REGIONS nr 
WHERE ae.NOC = nr.NOC 
GROUP BY nr.REGION
HAVING count(DISTINCT(games)) = (SELECT max(count(DISTINCT(games))) FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS GROUP BY NOC)
ORDER BY 2 desc;


--6. Identify the sport which was played in all summer Olympics.

SELECT  SPORT,count(DISTINCT(GAMES)) total_no_games_played 
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS 
WHERE GAMES  LIKE '%Summer%' 
GROUP BY SPORT
HAVING count(DISTINCT(games)) = (SELECT max(count(DISTINCT(games))) FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS GROUP BY SPORT)
ORDER BY 2 desc;

--7.	Which Sports were just played only once in the Olympics?

SELECT  SPORT,count(DISTINCT(GAMES))  games_palyed_once
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS 
WHERE GAMES  LIKE '%Summer%' 
GROUP BY SPORT
HAVING count(DISTINCT(games)) = 1
ORDER BY 2 desc;

--8.	Fetch the total no of sports played in each Olympics games.


SELECT  GAMES,count(DISTINCT(SPORT))  total_no_sports_played
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS 
GROUP BY GAMES
ORDER BY 2 desc;

--9.	Fetch details of the oldest athletes to win a gold medal.

WITH athelete_age AS
(SELECT ae.name,ae.sex,ae.games,ae.noc,ae.medal, cast(CASE WHEN age='NA' THEN '0' ELSE age end AS int) age
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae )
,ath_rnk AS (
SELECT ae.*,RANK () OVER (ORDER BY age desc) AS rnk
FROM  athelete_age ae WHERE medal='Gold')
SELECT * FROM ath_rnk WHERE rnk=1

--10.	Find the Ratio of male and female athletes participated in all Olympic games.
WITH male_player_cnt AS (
SELECT count(DISTINCT(name)) total_male_players_cnt 
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS
WHERE sex='M'
),
female_player_cnt AS (
SELECT count(DISTINCT(name)) total_femal_players_cnt 
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS
WHERE sex='F'
)
SELECT concat('1 : ', round(total_male_players_cnt/total_femal_players_cnt,2)) AS ratio
FROM male_player_cnt mc ,female_player_cnt fc

--11.  Fetch the top 5 athletes who have won the most gold medals.
WITH gold_medal_cnt AS (
SELECT  ae.name,ae.TEAM ,count(1) total_gold_medals
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae
WHERE medal='Gold'
GROUP BY ae.name,ae.TEAM
)
,top_ath AS(SELECT g.*, dense_rank() OVER (ORDER BY total_gold_medals desc) rnk 
FROM gold_medal_cnt g)
SELECT * FROM top_ath WHERE rnk <= 5;


--12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

SELECT DISTINCT medal FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae WHERE medal NOT LIKE 'NA'

WITH total_medal_cnt as(
SELECT  ae.name,ae.TEAM ,count(1) total_medals
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae
WHERE medal NOT LIKE 'NA'
GROUP BY ae.name,ae.TEAM
)
,top_ath AS (SELECT tc.*,dense_rank() OVER (ORDER BY total_medals desc) rnk FROM total_medal_cnt tc )
SELECT *
FROM top_ath WHERE rnk <=5

--13.	Fetch the top 5 most successful countries in Olympics. Success is defined by no of medals won.

WITH total_medal_cnt as(
SELECT  ae.TEAM ,count(1) total_medals
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae
WHERE medal NOT LIKE 'NA'
GROUP BY ae.TEAM
)
,top_team AS (SELECT tc.*,dense_rank() OVER (ORDER BY total_medals desc) rnk FROM total_medal_cnt tc )
SELECT *
FROM top_team WHERE rnk <=5

--14.	List down total gold, silver and bronze medals won by each country.

SELECT  
ae.TEAM ,
sum(case when medal='Gold' then 1 else 0 end) as gold_count,
sum(case when medal='Silver' then 1 else 0 end) as silver_count,
sum(case when medal='Bronze' then 1 else 0 end) as bronze_count
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae
WHERE medal NOT LIKE 'NA'
GROUP BY ae.TEAM
ORDER BY 2 desc ;

--15.	List down total gold, silver and bronze medals won by each country corresponding to each Olympic games
select TEAM ,games,
sum(case when medal='Gold' then 1 else 0 end) as gold_count,
sum(case when medal='Silver' then 1 else 0 end) as silver_count,
sum(case when medal='Bronze' then 1 else 0 end) as bronze_count
from SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS ae
WHERE medal NOT LIKE 'NA'
group by TEAM ,games
order by games ;

--16. Identify which country won the most gold, most silver and most bronze medals in each Olympic games.
with base as (
select 
oh.games,
noc.region as country,
oh.medal 
from SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS  oh
join SQLPORTFOLIOPROJECTS.noc_regions noc on oh.noc = noc.noc
where medal <> 'NA' ),
base_count as (
select games,country,
sum(case when medal ='Gold' then 1 else 0 end) over (partition by games,country) as count_gold,
sum(case when medal ='Silver' then 1 else 0 end) over (partition by games,country) as count_silver,
sum(case when medal ='Bronze' then 1 else 0 end) over (partition by games,country) as count_bronze
from base )-- select * FROM base_count
select 
distinct games,
concat(CONCAT(
first_value(country) over (partition by games order by count_gold desc),' - '),
first_value(count_gold) over (partition by games order by count_gold desc) 
) as max_gold,
concat(concat(
first_value(country) over (partition by games order by count_silver desc),' - '),
first_value(count_silver) over (partition by games order by count_silver desc)
) as max_silver,
concat(concat(
first_value(country) over (partition by games order by count_bronze desc),' - '),
first_value(count_bronze) over (partition by games order by count_bronze desc)
) as max_bronze
from base_count;


--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each Olympic games.

with base as (
select 
oh.games,
noc.region as country,
oh.medal 
from SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS  oh
join SQLPORTFOLIOPROJECTS.noc_regions noc on oh.noc = noc.noc
where medal <> 'NA' ),
base_count as (
select games,country,
sum(case when medal ='Gold' then 1 else 0 end) over (partition by games,country) as count_gold,
sum(case when medal ='Silver' then 1 else 0 end) over (partition by games,country) as count_silver,
sum(case when medal ='Bronze' then 1 else 0 end) over (partition by games,country) as count_bronze,
sum(1) over (partition by games,country) as total_medals_count
from base )-- select * FROM base_count
select 
distinct games,
concat(CONCAT(
first_value(country) over (partition by games order by count_gold desc),' - '),
first_value(count_gold) over (partition by games order by count_gold desc) 
) as max_gold,
concat(concat(
first_value(country) over (partition by games order by count_silver desc),' - '),
first_value(count_silver) over (partition by games order by count_silver desc)
) as max_silver,
concat(concat(
first_value(country) over (partition by games order by count_bronze desc),' - '),
first_value(count_bronze) over (partition by games order by count_bronze desc)
) as max_bronze,
concat(concat(
first_value(country) over (partition by games order by total_medals_count desc),' - '),
first_value(total_medals_count) over (partition by games order by total_medals_count desc)
) as max_medals
from base_count;





--18. Which countries have never won gold medal but have won silver/bronze medals?
WITH medal_cnt AS (
SELECT 
	team,
	CASE WHEN medal='Gold' THEN count(DISTINCT medal) OVER (PARTITION BY team) ELSE 0 END Gold_cnt,
	CASE WHEN medal='Silver' THEN count(DISTINCT medal) OVER (PARTITION BY team) ELSE 0 END silver_cnt,
	CASE WHEN medal='Bronze' THEN count(DISTINCT medal) OVER (PARTITION BY team) ELSE 0 END bronze_cnt
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS 
WHERE medal NOT LIKE 'NA' --AND team IN ('Thailand','Afghanistan','Tanzania')
)
SELECT DISTINCT TEAM , Gold_cnt,silver_cnt,bronze_cnt
FROM  medal_cnt 
WHERE Gold_cnt =0 AND (silver_cnt > 0 OR bronze_cnt > 0);

--19. In which Sport/event, India has won highest medals.
WITH ind_sport AS (SELECT SPORT ,event, count(medal) sport_cnt
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS 
WHERE medal NOT LIKE 'NA' AND NOC = 'IND' AND team='India'
GROUP BY SPORT ,event)
,top_sport_ind AS (SELECT i.*, DENSE_RANK() OVER (ORDER  BY sport_cnt DESC) rnk FROM ind_sport i)
SELECT * FROM top_sport_ind WHERE rnk=1

--20. Break down all Olympic games where India won medal for Hockey and how many medals in each Olympic games.


SELECT SPORT ,event,GAMES, count(medal) medal_cnt
FROM SQLPORTFOLIOPROJECTS.ATHLETE_EVENTS 
WHERE medal NOT LIKE 'NA' AND NOC = 'IND' AND team='India' AND SPORT ='Hockey'
GROUP BY SPORT ,event,GAMES 
ORDER BY 4 DESC




