
Select *
From PortfolioPROJECT..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioPROJECT..CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioPROJECT..CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioPROJECT..CovidDeaths
Where location like '%kenya%'
order by 1,2


-- Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, total_cases, population,(total_cases/population)*100 as PopulationPercentage
From PortfolioPROJECT..CovidDeaths
Where location like '%kenya%'
order by 1,2

--Countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PopulationPercentageInfected
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Group by Location, population
order by PopulationPercentageInfected desc

--Countries with Highest Death count per population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by Location
order by TotalDeathCount desc

--By Continent
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Continents with Highest death counts
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  SUM
	(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by date
order by 1,2

--Create View

create View GlobalNumbers as
Select date, SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  SUM
	(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
Group by date
--order by 1,2


--Next
Select SUM(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,  SUM
	(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioPROJECT..CovidDeaths
--Where location like '%kenya%'
Where continent is not null
--Group by date
order by 1,2



-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
From PortfolioPROJECT..CovidDeaths dea
Join PortfolioPROJECT..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
Where dea.continent is not null
order by 1,2,3


--USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
From PortfolioPROJECT..CovidDeaths dea
Join PortfolioPROJECT..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3
)

Select *, (RollingPeopleVaccinated/Population) * 100
From PopvsVac



--TEMP TABLE


IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
From PortfolioPROJECT..CovidDeaths dea
Join PortfolioPROJECT..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 1,2,3

Select *, (RollingPeopleVaccinated/Population) * 100
From #PercentPopulationVaccinated




--Creating View to store data for later visualizations

create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, 
	dea.date) as RollingPeopleVaccinated
--,	(RollingPeopleVaccinated/population)*100
From PortfolioPROJECT..CovidDeaths dea
Join PortfolioPROJECT..CovidVaccinations vac
	On dea.Location = vac.Location
	and dea.date = vac.date
Where dea.continent is not null
--order by 1,2,3


Select *
From PercentPopulationVaccinated
