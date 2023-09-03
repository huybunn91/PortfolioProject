SELECT [location], [date], total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE [location] like '%states%'
ORDER BY 1,2

-- Looking at Total Case Vs Population 
SELECT [location], [date], total_cases, population, (total_cases/population)*100
FROM CovidDeaths
WHERE [location] like '%states%'

-- Looking at Countries with Highest Inflection Rate compared to Population 
SELECT [location], population, MAX(total_cases) as HighestInflectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM CovidDeaths
GROUP BY [location], population
ORDER BY PercentPopulationInfected DESC

-- LET'S BREAK THINGS DOWN BY CONTINENT
SELECT [location], MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) AS TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY [location]
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBER
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths,
    CASE 
    WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths)/SUM(new_cases)*100 
END AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--GROUP BY [date]
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    ON dea.[location] = vac.[location]
        and dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3

-- USING CTE
WITH
    PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
    AS
    (
        SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
        FROM CovidDeaths dea
            JOIN CovidVaccinations vac
            ON dea.[location] = vac.[location]
                and dea.[date] = vac.[date]
        WHERE dea.continent IS NOT NULL
    )
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(50),
    Location NVARCHAR(50),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinated NUMERIC,
    RollingPeopleVaccinate NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
    JOIN CovidVaccinations vac
    ON dea.[location] = vac.[location]
        and dea.[date] = vac.[date]
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinate/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 2,3

-- Creating View to data for late visualizations
CREATE VIEW PercentPopulationVaccinated
AS
    SELECT dea.continent, dea.[location], dea.[date], dea.population, vac.new_vaccinations
, SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) AS RollingPeopleVaccinated
    FROM CovidDeaths dea
        JOIN CovidVaccinations vac
        ON dea.[location] = vac.[location]
            and dea.[date] = vac.[date]
    WHERE dea.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2,3
