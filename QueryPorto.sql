Select *
From Portfolio..CovidDeaths
-- Where continent is not null
order by 3,4

--Select *
--From Portfolio..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageofDeath
From Portfolio..CovidDeaths
order by 1,2

-- Looking at Total Deaths in Indonesia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentageofDeath
From Portfolio..CovidDeaths
Where location like '%Indonesia%'
order by 1,2

-- Looking of the percentage of being infected
Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentageofInfected
From Portfolio..CovidDeaths
--Where location like '%indonesia%'
order by 1,2

-- Looking at Country with highest infection rate compared to the population
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population)*100) as PercentageofInfected
From Portfolio..CovidDeaths
Group by location, Population
order by PercentageofInfected desc

-- Looking at Country with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by location, Population
order by TotalDeathCount desc


-- Break down by continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS. Per 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageofDeathperday
From Portfolio..CovidDeaths
Where continent is not null
--Group by date
order by 1,2

------Table Vaccinations
--Select * From Portfolio..CovidVaccinations

--Join 2 tables
--Select * From Portfolio..CovidDeaths dea
--Join Portfolio..CovidVaccinations vac
--On dea.location = vac.location
--and dea.date = vac.date

-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Making CTE (Common Table Expressions)
WITH PopsvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopsvsVac

-- Making TempTable
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Making View
CREATE VIEW PercentPopulationVaccinated AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

CREATE VIEW GlobalView AS
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totalDeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as PercentageofDeathperday
From Portfolio..CovidDeaths
Where continent is not null
--Group by date
--order by 1,2

CREATE VIEW HighestDeathCountView AS
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
Group by location, Population
--order by TotalDeathCount desc