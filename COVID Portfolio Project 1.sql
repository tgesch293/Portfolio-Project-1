SELECT * FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 3,4

-- SELECT Data that we are going to be using

/* SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2 */

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT Location, date, total_cases, total_deaths, ROUND((total_deaths/ total_cases)*100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Total Cases vs. Population
-- Shows what percentage of population got Covid
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Showing countries with Highest Death Count per Location
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Below is the correct query, but for purposes of this project we will write a different query

/* SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE Continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC
DELETE FROM PortfolioProject..CovidDeaths WHERE
Location IN ('High income', 'Lower middle income', 'Low income', 'Upper middle income') */

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
-- WHERE location LIKE '%states%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) AS NewCases, SUM(cast(new_deaths AS int)) AS NewDeaths,
SUM(cast(new_deaths AS int))/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, 
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, new_vaccinations, Population, RollingPeopleVaccinated)
AS
(
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, 
SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
--ORDER BY 2,3)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--Creating View to store data for later visualizations in Tableau

CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, vac.new_vaccinations, dea.population, 
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location, dea.Date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * FROM PercentPopulationVaccinated