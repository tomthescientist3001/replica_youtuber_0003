SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
ORDER BY 3, 4;


--Select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
ORDER BY 1, 2;


--Looking at Total Cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, 
    (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE 
    location LIKE '%states%'
    AND continent != ''
ORDER BY 1, 2;


--Looking at Total Cases vs Population
--Shows waht percentage of population got Covid

SELECT location, date, population, total_cases, 
	(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent!=''
ORDER BY 1, 2;

--Looking at countries with Highest Infection Rate compared to pupulation

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  
	MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent!=''
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc;


-- Showing countries with Highest Death Rate Count per Population

SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent!=''
GROUP BY location
ORDER BY TotalDeathCount desc;


-- LET'S BREAK THINGS DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent =''
GROUP BY location
ORDER BY TotalDeathCount desc;


-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent !=''
GROUP BY continent
ORDER BY TotalDeathCount desc;

-- Gloal Numbers

SELECT
	SUM(CAST(new_cases as int)) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths,
	(SUM(CAST(new_deaths as int)) * 100.0) / NULLIF(SUM(CAST(new_cases as int)), 0) as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent !=''
--Group by date
ORDER BY 1, 2;


-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY TRY_CONVERT(date, SUBSTRING(dea.date, 7, 4) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 103) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
	--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY TRY_CONVERT(date, SUBSTRING(dea.date, 7, 4) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 103);


-- USE cte

WITH PopvsVac AS (
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        TRY_CONVERT(date, SUBSTRING(dea.date, 7, 4) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 103) AS formatted_date,
        SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY TRY_CONVERT(date, SUBSTRING(dea.date, 7, 4) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 103) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
    FROM 
        PortfolioProject..CovidDeaths dea
    JOIN 
        PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE 
        dea.continent != ''
		AND dea.population != 0  -- Exclude rows where population is zero
)
SELECT 
    continent, 
    location, 
    date, 
    population, 
    new_vaccinations, 
	RollingPeopleVaccinated,
	CASE 
        WHEN population = 0 THEN 0
        ELSE (RollingPeopleVaccinated * 100.0 / NULLIF(population, 0))  -- Avoid division by zero 
    END AS vaccination_percentage
FROM 
    PopvsVac
ORDER BY 
    formatted_date;


--Temp table

IF OBJECT_ID('tempdb..#PercentagePopulationVaccinated') IS NOT NULL
DROP TABLE #PercentagePopulationVaccinated;

CREATE TABLE #PercentagePopulationVaccinated
	(
		continent NVARCHAR(255),
		location NVARCHAR(255),
		date DATETIME,
		population NUMERIC,
		RollingPeopleVaccinated NUMERIC
	);

INSERT INTO #PercentagePopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    CONVERT(DATETIME, SUBSTRING(dea.date, 7, 2) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 3) AS date,
    dea.population, 
    SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY CONVERT(DATETIME, SUBSTRING(dea.date, 7, 2) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 3) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE 
    dea.continent != ''
    AND dea.population != 0;  -- Exclude rows where population is zero

SELECT *,
    CASE 
        WHEN population = 0 THEN 0
        ELSE (RollingPeopleVaccinated * 100.0 / NULLIF(population, 0))  -- Avoid division by zero 
    END AS vaccination_percentage
FROM #PercentagePopulationVaccinated;


--Create view to store data for later visualizations

CREATE VIEW PercentagePopulationVaccinated AS
SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        TRY_CONVERT(date, SUBSTRING(dea.date, 7, 4) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 103) AS formatted_date,
        SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY TRY_CONVERT(date, SUBSTRING(dea.date, 7, 4) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 103) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent != '';


SELECT *
FROM PercentagePopulationVaccinated 