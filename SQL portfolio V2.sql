SELECT *
FROM [Portfolio Project]..[covid deaths]
WHERE continent is not NULL


--Select *
--from [Portfolio Project]..[covid vaccinations]
--order by 3,4

-- query 1

SELECT
location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..[covid deaths]
WHERE continent is not NULL
ORDER BY 1,2

-- query 2
-- Rough estimate of your risk of dying from covid in Nigeria
SELECT
location, date, total_cases, total_deaths, ((cast(total_deaths as float))/total_cases)*100 as deathpercent
FROM [Portfolio Project]..[covid deaths]
WHERE location='nigeria'
ORDER BY 1,2

--query 3
--what percentage of population got covid
SELECT
location, date, total_cases, population, (total_cases/population)*100 as percent_infected
FROM [Portfolio Project]..[covid deaths]
WHERE location like 'nigeria'
AND continent is not NULL
ORDER BY 1,2

--query 4
--what countries had the highest infection rates
SELECT
location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as percent_infected
FROM [Portfolio Project]..[covid deaths]
WHERE continent is not NULL
GROUP BY location, population
ORDER BY percent_infected desc

SELECT
location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as percent_infected
FROM [Portfolio Project]..[covid deaths]
WHERE continent='africa'
GROUP BY location, population
ORDER BY percent_infected desc

--query 5
--what countries had the highest death count
SELECT
location, continent, MAX(total_deaths) as DeathCount
FROM [Portfolio Project]..[covid deaths]
WHERE continent is not NULL
and continent='africa'
GROUP BY location, continent
ORDER BY DeathCount desc


--query 6
--continent with the highest death count
SELECT
location, MAX(total_deaths) as DeathCount
FROM [Portfolio Project]..[covid deaths]
WHERE continent is NULL
GROUP BY location
ORDER BY DeathCount desc

--query 7
--Global numbers
--death rate per day to number of cases
SELECT
    date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 -- NULL
        ELSE SUM(new_deaths)/SUM(new_cases)*100
    END AS deathpercent
FROM 
    [Portfolio Project]..[covid deaths]
WHERE 
    continent IS not NULL
GROUP BY 
	date
ORDER BY 
    1,2

-- total deaths and total cases
SELECT
    --date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_deaths, 
    CASE 
        WHEN SUM(new_cases) = 0 THEN 0 -- NULL
        ELSE SUM(new_deaths)/SUM(new_cases)*100
    END AS deathpercent
FROM 
    [Portfolio Project]..[covid deaths]
WHERE 
    continent IS not NULL
--GROUP BY date
ORDER BY 
    1,2

--query 8
-- total population vs total vaccinations
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations AS bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
FROM [Portfolio Project]..[covid deaths] dea
Join [Portfolio Project]..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--query 9
--percentage of the population that was vaccinated
--Use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, cumulative_vaccination)
as
(
Select 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations AS bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
FROM [Portfolio Project]..[covid deaths] dea
Join [Portfolio Project]..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (Cumulative_vaccination/population)*100 as Percent_vaccinated
FROM popvsvac

--using temptable
DROP TABLE if exists #Percentagepopulationvaccinated
CREATE TABLE #Percentagepopulationvaccinated (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinatons bigint,
cumulative_vaccination numeric
)

INSERT INTO #Percentagepopulationvaccinated
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations AS bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
FROM [Portfolio Project]..[covid deaths] dea
Join [Portfolio Project]..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (Cumulative_vaccination/population)*100 as Percent_vaccinated
FROM #Percentagepopulationvaccinated

--query 10
--creating view to store data for later visualization
CREATE VIEW Percentagepopulationvaccinated as
SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, 
	vac.new_vaccinations,
	Sum(cast(vac.new_vaccinations AS bigint)) 
	OVER(Partition by dea.location order by dea.location, dea.date) as cumulative_vaccination
from [Portfolio Project]..[covid deaths] dea
Join [Portfolio Project]..[covid vaccinations] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null


--selecting from the views
select *

FROM Percentagepopulationvaccinated

