Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3, 4


--Select *
--From PortfolioProject..CovidVaccinations
--order by 3, 4


Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2


-- Looking at Total Cases vs Total Deaths. Convert total deaths and total cases to float in order to calculate deathpercentage
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0)) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Jamaica'
and location is not null
order by 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select location, date, population, total_cases, (CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0)) * 100 AS ContractionPercentage
From PortfolioProject..CovidDeaths
Where location like 'Jamaica'
order by 1, 2


-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, max(total_cases) as HighestInfectionCount, max((CONVERT(float,total_cases)/NULLIF(CONVERT(float,population),0))) * 100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like 'Jamaica'
Group by location, population
order by PercentPopulationInfected desc


-- Showing Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Jamaica'
where continent is not null
Group by location
order by TotalDeathCount desc




-- Showing Continents with Highest Death Count per Population

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Jamaica'
where continent is not null
Group by continent
order by TotalDeathCount desc

select distinct location
from CovidDeaths




--Global Numbers

Select date, total_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(CONVERT(float,total_cases),0)) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Jamaica'
where continent is not null
order by 1, 2


Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, nullif(sum(new_deaths),0)/nullif(sum(new_cases),0) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Jamaica'
where continent is not null
group by date
order by 1, 2


-- Death Percentage globally

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, nullif(sum(new_deaths),0)/nullif(sum(new_cases),0) * 100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Jamaica'
where continent is not null
--group by date
order by 1, 2


-- Looking at total Population vs Vaccinations

Select*
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date

-- Rolling Total Vaccinations Globally

Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
order by 2,3





-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingTotalVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingTotalVaccinations/Population)*100
from PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingTotalVaccinations numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
--where dea.continent is not null
--order by 2,3
Select *, (RollingTotalVaccinations/Population)*100
from #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
SUM(convert(float,vacc.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,dea.date) as RollingTotalVaccinations
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vacc
	ON dea.location = vacc.location
	and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated