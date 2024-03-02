# Data Analyst Portfolio Project | Tableau Visualization | Project 2/4 by Alex The Analyst

### Disclaimer

This is a reproduction inspired by the youtuber Alex Freberg from the YouTube Channel [Alex The Analyst](https://www.youtube.com/@AlexTheAnalyst/featured)
- See original youtuve video [Data Analyst Portfolio Project | Tableau Visualization | Project 2/4](https://youtu.be/QILNlRvJlfQ?si=4yeXpPiyVlkIjTaj).
- Follow Alex in GitHub [AlexTheAnalyst](https://github.com/AlexTheAnalyst)

### Introduction

I have followed the video tutorial, but there were some issues, errors, and other obstacles that did not allow me to use the same code as his. However, I attempted to achieve similar results or as close as possible. I am still learning, and special thanks to Alex for his videos.

In this second video, four Excel files were made. Please, see attached in this repository.

### The SQL Queries

```SQL
-- 1. Global numbers
SELECT
	SUM(CAST(new_cases as int)) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths,
	(SUM(CAST(new_deaths as int)) * 100.0) / NULLIF(SUM(CAST(new_cases as int)), 0) as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent !=''
ORDER BY 1, 2;
```

```SQL
-- 2. We take these out as they are not inluded in the above queries and want to stay consistent. European Union is part of Europe
SELECT location, SUM(CAST(new_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE 
	continent =''
	AND location NOT IN ('World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc;
```

```SQL
-- 3. Finding countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  
	MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc;
```

```SQL
-- 4. Percent population infected
SELECT location, population, date, MAX(total_cases) as HighestInfectionCount,  
	MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected desc;
```

### Data Visualization

Please, see the results in [Tableau](https://public.tableau.com/app/profile/tomthescientist3001/viz/Dashboard001Repository0003/Dashboard1).
