SELECT TOP 5 * 
FROM CovidDeaths
;

SELECT TOP 5 *
FROM CovidVaccinations;


/* select Data that we are going to be using
*/
 SELECT Location, date, total_cases, new_cases, total_deaths, population
 FROM CovidDeaths
 ORDER BY 1,2;

 /* 
 Looking at the Total Cases vs Total Deaths
 Shows the likelihood of dying if you contract covid in South Africa 
 */
 
 SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
 FROM CovidDeaths
 WHERE Location LIKE '%South Africa%'
 ORDER BY 1,2;

 /*
 Looking at Total Cases vs Population
 shows what percentage of the population got Covid
 */

 SELECT Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulation_infected
 FROM CovidDeaths
 WHERE location LIKE '%South Africa%'
 ORDER BY 1,2;

 /* Looking at Countries with the Highest Infection Rate compared to population
 */

 SELECT Location, population, MAX(total_cases), MAX((total_cases/population))*100 as PercentPopulation_infected
 FROM CovidDeaths
 GROUP BY Location, population
 ORDER BY PercentPopulation_infected DESC;

 -- Showing Countries with Highest Death Count Per Population

 SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY Location
 ORDER BY TotalDeathCount DESC;


 -- Let's break things down by continet

 SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY continent
 ORDER BY TotalDeathCount DESC;

 -- Global Numbers

 SELECT  SUM(new_cases) AS Total_Case, SUM(cast(new_deaths as int)) AS Total_Deaths, 
 SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 --GROUP BY date
 ORDER BY 1,2;


 -- Looking at Total Population vs Vacicinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
 JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

 --USING A CTE

 WITH popvsvac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
 AS
 (
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CAST(vac.new_vaccinations as int)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
 FROM CovidDeaths dea
	JOIN CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

 WHERE dea.continent IS NOT NULL
 )

 SELECT *, (RollingPeopleVaccinated/population)*100
 FROM popvsvac;

 --Create view to store data for later visualizations

 CREATE VIEW DeathRatebyCountry AS
 SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
 FROM CovidDeaths
 WHERE continent IS NOT NULL
 GROUP BY Location;



