SELECT *
FROM CovidDeaths 
ORDER BY 3, 4

SELECT * 
FROM CovidVaccinations
ORDER BY 3, 4

SELECT 
	location
	, date
	, total_cases
	, new_cases
	, total_deaths
	, population
FROM CovidDeaths
ORDER BY 1, 2 

-- Looking at Total Cases vs Total Deaths
-- Showing likedlihood of dying if you contract covid in your country
SELECT 
	location
	, date
	, total_cases
	, total_deaths
	, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE location LIKE 'Austria'
ORDER BY 1, 2 

-- Looking at Total Cases vs Population
-- Showing What percentage of population got covid
SELECT 
	location
	, date
	, population
	, total_cases
	, (total_cases/population)*100 AS PercenPopulationInfected 
FROM CovidDeaths
WHERE location LIKE 'Austria'
ORDER BY 1, 2 

-- Looking at countries wwith Highest Infection rate compared to Population
SELECT 
	location
	, population
	, MAX(total_cases) AS HighestInfectionCount
	, MAX((total_cases/population))*100 AS PercenPopulationInfected  
FROM CovidDeaths
--WHERE location LIKE 'Austria'
GROUP BY location, population
ORDER BY PercenPopulationInfected DESC 

-- Showing Countries with Highest Death Count Per Population
--Lets break things down by continent
-- Showing Continets with Highest Death Count Per Population
SELECT 
	continent 
	, MAX(cast(total_deaths as int)) AS TotalDeathCount  
	-- ??i nvarchar sang int 
FROM CovidDeaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS 
SELECT 
	date
	, SUM(new_cases) AS Total_cases
	, SUM(cast(new_deaths AS INT)) AS Total_deaths
	, (SUM(cast(new_deaths AS INT))/SUM(new_cases))*100 AS DeathPercentage 
FROM CovidDeaths
--WHERE location LIKE 'Austria'
WHERE continent IS NOT NULL
GROUP BY date 
ORDER BY 1, 2 


-- Looking at Total Population vs Vaccinations 

SELECT 
	dea.continent
	, dea.location
	, dea.date
	, dea.population
	, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
		ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- USING CTE
WITH PopvsVac AS (
	SELECT 
		dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2, 3
)

SELECT *
	, (RollingPeopleVaccinated/population)*100 
FROM PopvsVac


-- USING TEMP TABLE 
DROP TABLE IF EXISTS #PercenPopulationVaccinated 
CREATE TABLE #PercenPopulationVaccinated (
	Continent nvarchar(255) 
	, location nvarchar(255)
	, date datetime
	, population numeric 
	, new_vaccinations numeric 
	, RollingPeopleVaccinated numeric 
)

INSERT INTO #PercenPopulationVaccinated 
	SELECT 
		dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2, 3

SELECT *
	, (RollingPeopleVaccinated/population)*100 
FROM #PercenPopulationVaccinated 


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS 

CREATE VIEW PercenPopulationVaccinated AS 
	SELECT 
		dea.continent
		, dea.location
		, dea.date
		, dea.population
		, vac.new_vaccinations
		, SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location 
			ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	FROM CovidDeaths AS dea
	JOIN CovidVaccinations AS vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
	--ORDER BY 2, 3