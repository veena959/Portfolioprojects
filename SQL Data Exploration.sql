select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..Covidvaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Australia%'
and continent is not null
order by 1,2

--looking at total cases vs population, shows what percentage of population got covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like '%Australia%'
and continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population
select location,  population, MAX(total_cases) as HighestInfectonCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Australia%'
group by location, population
order by PercentPopulationInfected desc

--showing countries with highest death count per population
select location,  max(cast(Total_deaths as int)) as totaldeathcount 
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Australia%'
group by location
order by totaldeathcount desc

--let's break things down by continent
--showing continents with the highest death count per population
select continent,  max(cast(Total_deaths as int)) as totaldeathcount 
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%Australia%'
group by continent
order by totaldeathcount desc

--global numbers
select date, sum(new_cases)--,  total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Australia%'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, 
sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as  DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Australia%'
where continent is not null
--group by date
order by 1,2

--Join
select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
	where dea.continent is not null
	order by 1,2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location)
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
	where dea.continent is not null
	order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte
with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as rollingpeoplevaccinated
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select * 
from popvsvac

with popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
	--order by 2,3
)
select *, (rollingpeoplevaccinated/population)*100
from popvsvac

--temp table
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location 
order by dea.location, dea.date) as rollingpeoplevaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
	where dea.continent is not null
	--order by 2,3
select *, (rollingpeoplevaccinated/population)*100
from #percentpopulationvaccinated

--creating view to store data for later visualizations

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as rollingpeoplevaccinated 
--, (rollingpeoplevaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..Covidvaccinations vac
	on dea.location = vac.location
	and	dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * 
from percentpopulationvaccinated