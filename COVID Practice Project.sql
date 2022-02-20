select * 
from COVIDPortfolioProject..[COVID Deaths]
where continent is not null
order by 3, 4

--select * 
--from COVIDPortfolioProject..[COVID Vaccinations]
--order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population 
from COVIDPortfolioProject..[COVID Deaths]
order by 1, 2

-- Likelihood of death after contracting COVID
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from COVIDPortfolioProject..[COVID Deaths]
where location like '%states%'
order by 1, 2

-- % of population that has gotten COVID
select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage 
from COVIDPortfolioProject..[COVID Deaths]
where location like '%states%'
order by 1, 2


-- Highest infection rates by country against population
select location, population, max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as CasesPercentage 
from COVIDPortfolioProject..[COVID Deaths]
group by location, population
order by CasesPercentage desc

-- Highest death rates per country
select location, max(cast(total_deaths as int)) as TotalDeaths
from COVIDPortfolioProject..[COVID Deaths]
where continent is not null
group by location, population
order by TotalDeaths desc

-- By Continent 
select location, max(cast(total_deaths as int)) as TotalDeaths
from COVIDPortfolioProject..[COVID Deaths]
where continent is null
group by location
order by TotalDeaths desc


-- Continents with highest death rates
select continent, max(cast(total_deaths as int)) as TotalDeaths
from COVIDPortfolioProject..[COVID Deaths]
where continent is not null
group by continent
order by TotalDeaths desc

-- Global numbers
-- By day
select date, sum(total_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from COVIDPortfolioProject..[COVID Deaths]
where continent is not null 
group by date
order by 1, 2
-- Total
select sum(total_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
from COVIDPortfolioProject..[COVID Deaths]
where continent is not null 
order by 1, 2

--Joining deaths and vaccinations data and looking at total population vs. vaccination
select *
from COVIDPortfolioProject..[COVID Deaths] death
join COVIDPortfolioProject..[COVID Vaccinations] vacc
	on death.location = vacc.location
	and death.date = vacc.date

select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, 
	death.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
from COVIDPortfolioProject..[COVID Deaths] death
join COVIDPortfolioProject..[COVID Vaccinations] vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
order by 2,3 

-- CTE
with PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, 
	death.date) as RollingPeopleVaccinated
from COVIDPortfolioProject..[COVID Deaths] death
join COVIDPortfolioProject..[COVID Vaccinations] vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac 

-- Temp Table
drop table if exists #PercentPopVaccinated
create table #PercentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

insert into #PercentPopVaccinated
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, 
	death.date) as RollingPeopleVaccinated
from COVIDPortfolioProject..[COVID Deaths] death
join COVIDPortfolioProject..[COVID Vaccinations] vacc
	on death.location = vacc.location
	and death.date = vacc.date
--where death.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopVaccinated 


-- Creating views
create view PercentPopVaccinated as
select death.continent, death.location, death.date, death.population, vacc.new_vaccinations
, sum(cast(vacc.new_vaccinations as bigint)) over (partition by death.location order by death.location, 
	death.date) as RollingPeopleVaccinated
from COVIDPortfolioProject..[COVID Deaths] death
join COVIDPortfolioProject..[COVID Vaccinations] vacc
	on death.location = vacc.location
	and death.date = vacc.date
where death.continent is not null


select * 
from PercentPopVaccinated