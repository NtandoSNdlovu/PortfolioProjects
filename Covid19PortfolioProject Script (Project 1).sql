-- Covid-19 Data Exploration 

-- Skills used: Joins, CTEs, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- In the original Data extracted from https://ourworldindata.org/covid-deaths, I noticed inconsistencies such as continents, 'International' and 'World' being placed in the 'location' column.
-- I considered this when creating my queries to achieve consistent and accurate results.
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- DATA USED IN TABLEAU VISUALISATIONS

-- 1A. DEATH PERCENTAGE - WORLD


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/SUM(New_Cases)*100 AS DeathPercentage
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not null 
ORDER BY 1,2

-- 2A. TOTAL DEATH COUNT PER CONTINENT 

SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM Covid19PortfolioProject.dbo.CovidDeaths
--Where location like '%states%'
WHERE continent is null 
and location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount DESC

-- 3A. HIGHEST INFECTION RATE PER COUNTRY

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE Location not in ('World', 'European Union', 'International')
GROUP BY Location, Population
ORDER BY PercentOfPopulationInfected DESC

-- 4A. HIGHEST INFECTION RATE PER COUNTRY - PER DAY

SELECT Location, Population,date, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentOfPopulationInfected
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE Location not in ('World', 'European Union', 'International')
GROUP BY Location, Population, date
ORDER BY PercentOfPopulationInfected DESC

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- OTHER QUERIES (NOT VISUALISED) - FOR THE SAKE OF SHOWCASING MY ABILITY AND SKILLS
-- More defined to include date, Continent and location for drill-through visualisations  



-- 1B. TOTAL CASES VS TOTAL DEATHS [Risk of death] - RSA
SELECT Continent, location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE location =  'South Africa'
ORDER BY 1, 2; 

-- 2B. TOTAL CASES VS POPULATION - RSA

SELECT location, date, total_cases, population, (total_cases/population) *100 AS PercentOfPopulationInfected 
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE location =  'South Africa'
ORDER BY 1, 2;

-- 3B. COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO THE POPULATION

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, (MAX((total_cases/population)) *100) AS PercentOfPopulationInfected 
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY PercentOfPopulationInfected DESC; 

-- 4B. COUNTRIES WITH THE HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC; 

-- 5B. CONTINENTS HIGHEST DEATH COUNT PER POPULATION

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- 6B. GLOBAL NUMBERS

SELECT date, SUM (new_cases) AS total_cases, SUM (CAST(new_deaths AS int))AS total_deaths, SUM (CAST (new_deaths AS int))/Sum (new_cases) *100 AS DeathPercentage
FROM Covid19PortfolioProject.dbo.CovidDeaths
Where continent is NOT NULL 
GROUP BY Date
ORDER BY 1, 2; 


-- 7B. TOTAL POPULATION VS VACCINATIONS (RollingTotalVaccinations)

-- {*Total Vaccinations is present in the vaccinations table, However I wanted to showcase
-- my abiities by calculating the rolling count to get to the Total Vacinnations.} 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(new_vaccinations AS int))
OVER (PARTITION BY dea.location Order By dea.location, dea.date) AS RollingTotalVaccinations
FROM Covid19PortfolioProject..CovidDeaths dea
INNER JOIN Covid19PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent Is NOT NULL
ORDER BY 2,3 

-- 8B(1). USE CTE to Calculate popvsVac - Because you can't create a column based on an Alias in the same statement

WITH PopvsVac (Continent, location, Date, Population, new_vaccinations, RollingTotalVaccinations)
 AS
(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(new_vaccinations AS int))
OVER (PARTITION BY dea.location Order By dea.location, dea.date) AS RollingTotalVaccinations
FROM Covid19PortfolioProject..CovidDeaths dea
INNER JOIN Covid19PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent Is NOT NULL
)
SELECT *, (RollingTotalVaccinations/Population) *100 AS PercentOfPopulationVaccinated 
FROM PopvsVac  

-- 8B (2). USING TEMP TABLE INSTEAD

DROP TABLE IF EXISTS #PercentOfPopulationVaccinated
CREATE TABLE #PercentOfPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingTotalVaccinations numeric)

INSERT into #PercentOfPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(new_vaccinations AS int))
OVER (PARTITION BY dea.location Order By dea.location, dea.date) AS RollingTotalVaccinations
FROM Covid19PortfolioProject..CovidDeaths dea
INNER JOIN Covid19PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent Is NOT NULL

SELECT *, (RollingTotalVaccinations/Population) *100 
FROM #PercentOfPopulationVaccinated


--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CREATE VIEWS 

-- VIEW: TOTAL CASES VS TOTAL DEATHS [Risk of death] - RSA

CREATE VIEW TotalCasesVsDeaths as
SELECT Continent, location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS DeathPercentage
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE location =  'South Africa'

-- 2C. VIEW: TOTAL CASES VS POPULATION - RSA
CREATE VIEW TotalCasesVsPopulation AS
SELECT location, date, total_cases, population, (total_cases/population) *100 AS PercentOfPopulationInfected 
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE location =  'South Africa'

-- 3C. VIEW: COUNTRIES - INFECTION RATE COMPARED TO POPULATION
CREATE VIEW C_PopulationInfectionRate AS
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, (MAX((total_cases/population)) *100) AS PercentOfPopulationInfected 
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location, population

-- 4C. COUNTRIES - DEATH COUNT PER POPULATION
CREATE VIEW C_DeathCountPerPopulation AS
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY location

-- 5C. CONTINENTS - DEATH COUNT PER POPULATION
CREATE VIEW Cont_DeathCountPerPopultaion AS
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM Covid19PortfolioProject.dbo.CovidDeaths
WHERE continent is not NULL
GROUP BY continent

-- 6C. GLOBAL NUMBERS

CREATE VIEW GlobalNumbers AS
SELECT date, SUM (new_cases) AS total_cases, SUM (CAST(new_deaths AS int))AS total_deaths, SUM (CAST (new_deaths AS int))/Sum (new_cases) *100 AS DeathPercentage
FROM Covid19PortfolioProject.dbo.CovidDeaths
Where continent is NOT NULL 
GROUP BY Date

-- 7C. TOTAL POPULATION VS VACCINATIONS (RollingTotalVaccinations)

CREATE VIEW RollingTotalVaccinations AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM (CAST(new_vaccinations AS int))
OVER (PARTITION BY dea.location Order By dea.location, dea.date) AS RollingTotalVaccinations
FROM Covid19PortfolioProject..CovidDeaths dea
INNER JOIN Covid19PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent Is NOT NULL












