select *
from PortfolioProject1..CovidDeath$
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject1..CovidDeath$
order by 1,2

--TotalDeaths Vs TotalCases
--DeathPercentage
select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100  as DeathPercentage
from PortfolioProject1..CovidDeath$
where location like '%india%'
order by 1,2

--TotalCases Vs Population
--Percentage of people got covid
select location, date, total_cases, population, (total_cases/population)*100  as CovidPercentage
from PortfolioProject1..CovidDeath$
--where location like '%india%'
order by 1,2

--Countries with Highest InfectionRate compared to the population
select location, population, Max(total_cases) as TotalCount, max((total_cases/population)*100) as HighInfectionRate
from PortfolioProject1..CovidDeath$
--where location like '%india%'
Group by location, population
order by HighInfectionRate desc

--Countries with highest total death count
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeath$
--where location like '%india%'
where continent != ''
Group by location
order by TotalDeathCount desc

--Break down by continent
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeath$
--where location like '%india%'
where continent = ''
Group by location
order by TotalDeathCount desc

select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject1..CovidDeath$
--where location like '%india%'
where continent != ''
Group by continent
order by TotalDeathCount desc

--Global Numbers
select date, sum(new_cases), sum(new_deaths), (sum(new_deaths)/Nullif(sum(new_cases),0))*100  as DeathPercentage
from PortfolioProject1..CovidDeath$
--where location like '%india%'
group by date
order by 1,2

select  sum(new_cases) as TotalCaseCount, sum(new_deaths) as TotalDeathCount, (sum(new_deaths)/Nullif(sum(new_cases),0))*100  as DeathPercentage
from PortfolioProject1..CovidDeath$
--where location like '%india%'
--group by date
order by 1,2


--TotalPopulation Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject1..CovidDeath$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent != ''
order by 2,3

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from PortfolioProject1..CovidDeath$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent != ''
order by 2,3

--With CTE
with popvsmac(Continent, Location, Date, Population, New_Vaccinations, TotalPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from PortfolioProject1..CovidDeath$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent != ''
--order by 2,3
)
select *, (TotalPeopleVaccinated/Population)*100
from popvsmac
order by Location, Date

--Temp Table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations nvarchar(255),
TotalPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from PortfolioProject1..CovidDeath$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent != ''
--order by 2,3
select *, (TotalPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated
order by Location, Date

--creating views
create view PercentPopulationVaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from PortfolioProject1..CovidDeath$ dea
join PortfolioProject1..CovidVaccinations$ vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent != ''
--order by 2,3
select *
from PercentPopulationVaccinated