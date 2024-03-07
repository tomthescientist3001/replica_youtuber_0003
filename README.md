### Disclaimer

This is a reproduction inspired by the youtuber Alex Freberg from the YouTube Channel [Alex The Analyst](https://www.youtube.com/@AlexTheAnalyst/featured).
- Follow Alex in GitHub [AlexTheAnalyst](https://github.com/AlexTheAnalyst)


### Table of Contents

- [Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4 by Alex The Analyst](#data-analyst-portfolio-project--sql-data-exploration--project-14-by-alex-the-analyst)

	- Introduction
	- SQL Queries
 	
- [Data Analyst Portfolio Project | Tableau Visualization | Project 2/4 by Alex The Analyst](#data-analyst-portfolio-project--tableau-visualization--project-24-by-alex-the-analyst)

	- Introduction
	- SQL Queries
	- Data Visualization

- [Data Analyst Portfolio Project | Data Cleaning in SQL | Project 3/4 by Alex The Analyst](#data-analyst-portfolio-project--data-cleaning-in-sql--project-34-by-alex-the-analyst)

	- Introduction
	- SQL Queries

- [Data Analyst Portfolio Project | Correlation in Python | Project 4/4 by Alex The Analyst](#data-analyst-portfolio-project--correlation-in-python--project-44-by-alex-the-analyst)

	- Introduction
	- Python Commands


<br>

---

# Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4 by Alex The Analyst
- See original YouTube video [Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4](https://youtu.be/qfyynHBFOsM?si=QQxuoH__eQmc3A41)

### Introduction

I have followed the video tutorial, but there were some issues, errors, and other obstacles that did not allow me to use the same code as his. However, I attempted to achieve similar results or as close as possible. I am still learning, and special thanks to Alex for his videos.

To import the Excel files into SQL Server, I saved them both as CSV files. Then, I imported them by following these steps:

1. Right-clicked on the database 'PortfolioProject'.
2. Selected 'Tasks' and then 'Import Data'.
3. In the pop-up window, selected 'Flat File Source' as the source.
4. Browsed for the data files in CSV format. While browsing, changed the format from 'text files' to 'CSV'.
5. For the destination, selected 'Microsoft OLE DB Provider for SQL Server'.


### SQL Queries

```SQL
-- Selecting all columns from CovidDeaths where continent is not empty and ordering by the 3rd and 4th columns
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
ORDER BY 3, 4;
```

```SQL
-- Selecting specific columns from CovidDeaths where continent is not empty and ordering by location and date
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent != ''
ORDER BY 1, 2;
```

```SQL
-- Calculating death percentage based on total cases and total deaths for states
SELECT location, date, total_cases, total_deaths, 
    (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE 
    location LIKE '%states%'
    AND continent != ''
ORDER BY 1, 2;
```

```SQL
-- Calculating percentage of population infected by Covid for each location
SELECT location, date, population, total_cases, 
	(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent!=''
ORDER BY 1, 2;
```

```SQL
-- Finding countries with the highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount,  
	MAX((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 as PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE continent!=''
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc;
```

```SQL
-- Finding countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent!=''
GROUP BY location
ORDER BY TotalDeathCount desc;
```

```SQL
-- Breaking down death count by continent
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent =''
GROUP BY location
ORDER BY TotalDeathCount desc;
```

```SQL
-- Finding continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent !=''
GROUP BY continent
ORDER BY TotalDeathCount desc;
```

```SQL
-- Global numbers
SELECT
	SUM(CAST(new_cases as int)) as total_cases, 
	SUM(CAST(new_deaths as int)) as total_deaths,
	(SUM(CAST(new_deaths as int)) * 100.0) / NULLIF(SUM(CAST(new_cases as int)), 0) as Deathpercentage
FROM PortfolioProject..CovidDeaths
WHERE continent !=''
--Group by date
ORDER BY 1, 2;
```

```SQL
-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.location ORDER BY CONVERT(DATETIME, SUBSTRING(dea.date, 7, 2) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 3) ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent != ''
ORDER BY CONVERT(DATETIME, SUBSTRING(dea.date, 7, 2) + '-' + SUBSTRING(dea.date, 4, 2) + '-' + SUBSTRING(dea.date, 1, 2), 3);
```

```SQL
-- Using a common table expression (CTE) to calculate population vs vaccinations
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
```

```SQL
-- Creating a temporary table to store data
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

-- Populating the temporary table
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

-- Selecting data from the temporary table with added vaccination percentage
SELECT *,
    CASE 
        WHEN population = 0 THEN 0
        ELSE (RollingPeopleVaccinated * 100.0 / NULLIF(population, 0))  -- Avoid division by zero 
    END AS vaccination_percentage
FROM #PercentagePopulationVaccinated;
```

```SQL
-- Creating a view to store data for later visualizations
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
```

```SQL
-- Selecting all data from the view
SELECT *
FROM PercentagePopulationVaccinated;
```

<br>

---

# Data Analyst Portfolio Project | Tableau Visualization | Project 2/4 by Alex The Analyst

- See original YouTube video [Data Analyst Portfolio Project | Tableau Visualization | Project 2/4](https://youtu.be/QILNlRvJlfQ?si=4yeXpPiyVlkIjTaj).

### Introduction

I have followed the video tutorial, but there were some issues, errors, and other obstacles that did not allow me to use the same code as his. However, I attempted to achieve similar results or as close as possible. I am still learning, and special thanks to Alex for his videos.

In this second video, four Excel files were made. Please, see attached in this repository.

### SQL Queries

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

<br>

---

# Data Analyst Portfolio Project | Data Cleaning in SQL | Project 3/4 by Alex The Analyst
- See original youtuve video [Data Analyst Portfolio Project | Data Cleaning in SQL | Project 3/4](https://youtu.be/8rO7ztF4NtU?si=KwfYiSd5jQ8g-b4g)

### Introduction

I have followed the video tutorial, but there were some issues, errors, and other obstacles that did not allow me to use the same code as his. However, I attempted to achieve similar results or as close as possible. I am still learning, and special thanks to Alex for his videos.

To import the Excel file file "Nashville Housing Data for Data Cleaning" into SQL Server, I saved it as CSV UTF-8 (comma delimited)". Then, I imported it by following these steps:

1. Right-clicked on the database 'PortfolioProject'.
2. Selected 'Tasks' and then 'Import Flat File'.
3. Follow the following YouTube video [How to import data from Microsoft Excel into Microsoft SQL Server](https://youtu.be/iGzBgd0qwT4?si=sVhCvETfY2Zpw3My) from the YouTube Channel [SQL Server 101](https://www.youtube.com/@SQLServer101).

### SQL Queries

```SQL
-- Cleaning data in SQL queries
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
```

```SQL
-- Standarise data format
SELECT SaleDate, CONVERT (date, SaleDate)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (date, SaleDate)
```

```SQL
-- Populate property address data
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL
```

```SQL
-- Breaking out address into individual columns ( Address, City, State)
SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
```

```SQL
-- Breaking out owner name into individual columns ( Address, City, State)
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
```

```SQL
-- Change Y and N to YES and NO in sold as "Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = '1' THEN 'Yes'
		 WHEN SoldAsVacant = '0' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 	CASE WHEN SoldAsVacant = '1' THEN 'Yes'
						 WHEN SoldAsVacant = '0' THEN 'No'
						 ELSE SoldAsVacant
						 END
```

```SQL
-- Remove duplicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, 
					 PropertyAddress, 
					 SalePrice, 
					 SaleDate, 
					 LegalReference
		ORDER BY UniqueID) ROW_NUM
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE ROW_NUM > 1
ORDER BY PropertyAddress
```

```SQL
-- Delete unused columns
SELECT *
FROM PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate
```

<br>

---

# Data Analyst Portfolio Project | Correlation in Python | Project 4/4 by Alex The Analyst
- See original YouTube video [Data Analyst Portfolio Project | SQL Data Exploration | Project 1/4](https://youtu.be/iPYVYBtUTyE?si=23ubfGuuQeJgepPZ)

### Introduction

I have followed the video tutorial, but there were some issues, errors, and other obstacles that did not allow me to use the same code as his. However, I attempted to achieve similar results or as close as possible. I am still learning, and special thanks to Alex for his videos.

### Python Commands

```Python
-- Installation of the libraries into python environment.
!pip install pandas
!pip install seaborn
!pip install matplotlib
!pip install numpy
```

```Python
import pandas as pd
import seaborn as sns
import numpy as np

import matplotlib
import matplotlib.pyplot as plt
plt.style.use('ggplot')
from matplotlib.pyplot import figure

%matplotlib inline
matplotlib.rcParams['figure.figsize'] = (12,8) # Adjusts the configuration of the plots we will create

# Read in the data --df = data drame

df = pd.read_csv(r'C:\Users\Tom\Downloads\movies.csv')
```

```Python
# Let's look at data
df.head()
```

```Python
# Let's see if there is any missing data
for col in df.columns:
    pct_missing = np.mean(df[col].isnull())
    print('{} - {}%'.format(col, pct_missing))
```

```Python
# Data types for our columns
df.dtypes
```

```Python
# Change data type of columns
df['budget'] = pd.to_numeric(df['budget'], errors='coerce').fillna(0).astype(int)
df['gross'] = pd.to_numeric(df['gross'], errors='coerce').fillna(0).astype(int)
df['votes'] = pd.to_numeric(df['votes'], errors='coerce').fillna(0).astype(int)
```

```Python
