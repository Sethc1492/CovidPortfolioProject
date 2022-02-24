SELECT *
FROM PortfolioProject.dbo.CovidVaccinations
WHERE continent is not null
ORDER BY 3,4



--Select the data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--qSHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--SHOWS WHAT PERCENTAGE OF POPULATION THAT CONTRACTED COVID

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject.dbo.CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--LOOKING AT WHAT COUNTRIES HAVE THE HIGHEST INFECTION RATE VS POPULATION

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 AS CasePercentage
FROM PortfolioProject.dbo.CovidDeaths
GROUP BY location, population
ORDER BY CasePercentage desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT
--SHOWING THE CONTINENT WITH HIGHEST DEATH COUNT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject.dbo.CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

CREATE VIEW GlobalCases as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage--, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject.dbo.CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location 
ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject.dbo.CovidDeaths as dea
JOIN PortfolioProject.dbo.CovidVaccinations as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated