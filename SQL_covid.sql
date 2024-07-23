SELECT *
FROM covid.dbo.CovidDeaths$
ORDER BY 3,4

SELECT *
FROM covid.dbo.CovidVaccinat$
ORDER BY 3,4

--Select data that going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid.dbo.CovidDeaths$
ORDER BY 1,2

-- Looking at Total Case VS Total Deaths
SELECT Location, date, total_cases, total_deaths,
		(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS death_persentage
FROM covid.dbo.CovidDeaths$
ORDER BY 1,2

-- Total Cases vs Population
SELECT location, date, total_cases, population,
		(total_cases/population)*100 AS case_persent
FROM covid.dbo.CovidDeaths$
ORDER BY 1,2

-- Countries with Highest Infection Rate compared to Population
SELECT location, population, 
		MAX(total_cases) AS max_cases,
		MAX((total_cases/population)*100) AS population_persent_infected
FROM covid.dbo.CovidDeaths$
GROUP BY location, population
ORDER BY max_cases DESC

-- Countries with Highest Death Count per Population
SELECT location, population, 
		MAX(cast(total_deaths as int)) AS max_deaths
FROM covid.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_deaths DESC


SELECT continent, 
		MAX(cast(total_deaths as int)) AS total_deaths
FROM covid.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_deaths DESC

-- Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) As rolling_people_vaccinated
FROM covid.dbo.CovidDeaths$ dea
JOIN covid.dbo.CovidVaccinat$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE 
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population,
		vac.new_vaccinations,
		SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) As rolling_people_vaccinated
FROM covid.dbo.CovidDeaths$ dea
JOIN covid.dbo.CovidVaccinat$ vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT * , (rolling_people_vaccinated/Population)*100 AS people_vaccinated_percent
FROM PopvsVac

