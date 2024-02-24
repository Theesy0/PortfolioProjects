update PortfolioProject..CovidDeaths
set new_cases=null
where new_cases='0'

Select *
From PortfolioProject..CovidDeaths
order by 4

Select *
From PortfolioProject..CovidVaccinations

Alter table PortfolioProject..CovidDeaths
Alter column total_deaths float
Alter table PortfolioProject..CovidDeaths
Alter column total_cases float
Alter table PortfolioProject..CovidVaccinations
Alter column new_vaccinations float

-- Looking at Total Cases vs Total Deaths
-- Shows likelyhood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentages
From PortfolioProject..CovidDeaths
Where location like '%nam%'
order by 1,2

--  Looking at Total Cases vs Population

Select location, date, total_cases, population, (total_cases/population) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%nam'
order by 1,2

-- Lookimh at country with highest infection rate to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%nam'
Group by location, population
order by PercentPopulationInfected desc

-- Showing countries with highest death count per population

Select location, Max(cast(total_deaths as int )) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%nam'
where continent is not null
Group by location
order by TotalDeathCount desc

-- Looking at continent

-- Showing continents with highest death count per population

Select location, Max(cast(total_deaths as int )) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%nam'
where continent is null
Group by location
order by TotalDeathCount desc

-- Global Number 

Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(cast(new_cases as int))) *100 as DeathPercentages
From PortfolioProject..CovidDeaths
--Where location like '%nam%'
where continent is not null 
Group by date
order by 1,2

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(cast(new_cases as int))) *100 as DeathPercentages
From PortfolioProject..CovidDeaths
--Where location like '%nam%'
where continent is not null 
--Group by date
order by 1,2

-- Looking at Total Population vs Vaccintaions

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

-- use CTE

With PopvsVac (Continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp table
drop table if exist #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric, 
new_vaccination numeric, 
RollingPeopleVaccinated numeric)
insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	Select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visulization

create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
--	order by 2,3

	Select *
from PercentPopulationVaccinated