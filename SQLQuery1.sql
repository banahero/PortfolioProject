select * 
from [PortfolioProject]..['Covid Deaths $']
where continent is not null
order by 3,4
 
 --select * 
--from [PortfolioProject]..['Covid Vaccinations $']
--order by 3,4

--Select Data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from [PortfolioProject]..['Covid Deaths $']
order by 1,2 

-- Looking at total cases vs total Deaths per cases
-- Shows likelyhood of dying if you contract covid in yoru country 

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From [PortfolioProject]..['Covid Deaths $']
Where location like '%ghana%'
order by 1,2 

--Looking at Total Cases vs Population
--Shows what percentage of population got covid

select location,date,population,total_cases, (total_cases/population)*100 as PercentPopulationinfected
From [PortfolioProject]..['Covid Deaths $']
--Where location like '%Ghana%'
order by 1,2

-- Looking at countries with hightest Infection rates per locations 

select location,population,MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationinfected
From [PortfolioProject]..['Covid Deaths $']
--Where location like '%Ghana%'
group by population, location
order by PercentPopulationinfected desc

-- Showing countires with Highest Death Count Per Population 

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..['Covid Deaths $']
--Where location like '%Ghana%'
where continent is not null
group by location
order by TotalDeathCount desc


-- Lets Break things out by continent


-- showing continents with the highest death count per population 

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [PortfolioProject]..['Covid Deaths $']
--Where location like '%Ghana%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- GLOBAL Numbers

select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentages
From [PortfolioProject]..['Covid Deaths $']
--Where location like '%ghana%'
Where continent is not null
group by date
order by 1,2 

-- across the world 
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentages
From [PortfolioProject]..['Covid Deaths $']
--Where location like '%ghana%'
Where continent is not null
--group by date
order by 1,2 

--Looking at Total Population vs Vaccaination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations 
From [PortfolioProject]..['Covid Deaths $'] dea
Join [PortfolioProject]..['Covid Vaccinations $'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3 

-- Rolling count 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
 SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
--,(rollingPeopleVaccinated/population)*100
From [PortfolioProject]..['Covid Deaths $'] dea
Join [PortfolioProject]..['Covid Vaccinations $'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3 


--USE CTE 
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rollingPeopleVaccinated) 
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
From [PortfolioProject]..['Covid Deaths $'] dea
Join [PortfolioProject]..['Covid Vaccinations $'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
select *,(rollingPeopleVaccinated/Population)*100 
from PopvsVac

--Temp Table


--DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccintation numeric,
rollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
From [PortfolioProject]..['Covid Deaths $'] dea
Join [PortfolioProject]..['Covid Vaccinations $'] vac
on dea.location = vac.location
and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

select *,(rollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated\

--Creating view to use later

Create View PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.location, dea.date) as rollingPeopleVaccinated
--(rollingPeopleVaccinated/population)*100
From [PortfolioProject]..['Covid Deaths $'] dea
Join [PortfolioProject]..['Covid Vaccinations $'] vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3 