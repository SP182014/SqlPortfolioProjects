SELECT * FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS c 
WHERE CONTINENT  IS NOT NULL ORDER BY 3,4 desc;

--SELECT count(1) FROM SQLPORTFOLIOPROJECTS.COVIDVACCINATIONS cv where location='Afghanistan'; --215178
--SELECT count(1) FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS cd where location='Afghanistan'; ----215178

--select data that we are going to be using

SELECT
	location,
	to_date("date",'DD/MM/YYYY') coviddate ,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT  IS NOT NULL
ORDER BY 1,2;

--Looking for Total cases vs Total deaths
--Shows the likelihood of dying if you contract covid in your own country
SELECT 
	location,
	to_date("date",'DD/MM/YYYY') coviddate ,
	total_cases,
	total_deaths,
	CASE WHEN total_deaths > 0 THEN (total_deaths/total_cases)*100 ELSE 0 END DeathPerc
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT  IS NOT NULL
AND location = 'India'
ORDER BY 1,2;


--Looking for Total cases vs Population
--Shows the percentage of population contracted with covid
SELECT 
	location,
	to_date("date",'DD/MM/YYYY') coviddate ,
	total_cases,
	POPULATION ,
	(total_cases/POPULATION)*100 CovidCasePerc
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT  IS NOT NULL 
AND location = 'United States'
ORDER BY 1,2;

--Looking at countries with highest infection rate compared to population

SELECT 
	location,
	POPULATION,
	max(TOTAL_CASES) HighestInfectionCount,
	max((TOTAL_CASES/POPULATION))*100 CovidCasePerc
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT  IS NOT NULL
GROUP BY location,POPULATION
ORDER BY CovidCasePerc desc;

--Looking at countries with highest Death count compared to population

SELECT 
	location,
	POPULATION,
	max(TOTAL_DEATHS) TotalDeathCount
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY location,POPULATION
HAVING max(TOTAL_DEATHS) IS NOT NULL
ORDER BY TotalDeathCount desc;

--Looking at continent with highest Death count compared to population

SELECT 
	CONTINENT ,
	max(TOTAL_DEATHS) TotalDeathCount
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY CONTINENT
HAVING max(TOTAL_DEATHS) IS NOT NULL
ORDER BY TotalDeathCount desc;

--New Cases coming up Globally

SELECT 
	to_date("date",'DD/MM/YYYY') coviddate ,
	sum(NEW_CASES) NewCasesCount
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT IS NOT NULL
GROUP BY to_date("date",'DD/MM/YYYY')
ORDER BY 1,NewCasesCount desc;

-- Global Numbers

SELECT 
	--to_date("date",'DD/MM/YYYY') coviddate ,
	sum(NEW_CASES) TotalCases,
	sum(NEW_DEATHS) TotalDeaths,
	sum(NEW_DEATHS)/sum(NEW_CASES) AS DeathPerc
FROM SQLPORTFOLIOPROJECTS.COVIDDEATHS
WHERE CONTINENT IS NOT NULL  
--GROUP BY to_date("date",'DD/MM/YYYY')
HAVING sum(NEW_CASES) IS NOT NULL 
ORDER BY 1,2 desc;

--looking at Total population vs vaccinations
WITH  TotalVaccinations AS
(
SELECT 
	cd.CONTINENT ,
	cd.LOCATION ,
	to_date(cd."date",'DD/MM/YYYY') coviddate ,
	cd.POPULATION ,
	cv.new_vaccinations,
	sum(cv.new_vaccinations) OVER (PARTITION BY cv.LOCATION ORDER BY cv.location,to_date(cv."date",'DD/MM/YYYY')) RollingPeoplevaccinated
FROM 
	SQLPORTFOLIOPROJECTS.COVIDDEATHS cd
	INNER JOIN SQLPORTFOLIOPROJECTS.COVIDVACCINATIONS cv  
	ON cd.LOCATION = cv.LOCATION
		AND to_date(cd."date",'DD/MM/YYYY')  = to_date(cv."date",'DD/MM/YYYY')
WHERE 
	cd.CONTINENT IS NOT NULL
	--AND cd.LOCATION IN ('Afghanistan','Albania') 
--ORDER BY 2,3 DESC
)
SELECT 
	CONTINENT,
	LOCATION,
	coviddate,
	POPULATION,
	new_vaccinations,
	RollingPeoplevaccinated,
	(RollingPeoplevaccinated/POPULATION)*100
FROM 
	TotalVaccinations

/*SELECT location,sum(new_vaccinations) 
FROM SQLPORTFOLIOPROJECTS.COVIDVACCINATIONS
WHERE CONTINENT IS NOT NULL
GROUP BY location
ORDER BY 1 */



